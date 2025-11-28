#!/usr/bin/env node

/**
 * 정책 상세 정보 동기화 스크립트
 * 
 * DB에 있는 정책들의 상세 정보를 온통청년 API에서 가져와서 업데이트합니다.
 * 목록 API에서는 기본 정보만 제공되므로, 상세 API를 호출하여
 * 지원내용(plcySprtCn), 신청방법(plcyAplyMthdCn) 등의 상세 필드를 채웁니다.
 */

const axios = require('axios');
const db = require('../config/database');
require('dotenv').config();

const API_KEY = process.env.ONTONG_API_KEY;
const BASE_URL = 'https://www.youthcenter.go.kr/go/ythip/getPlcy';

// API 호출 간격 (ms) - API 부하 방지
const API_DELAY = 300;

// 한 번에 처리할 정책 수
const BATCH_SIZE = 50;

/**
 * 정책 상세 정보 가져오기
 */
async function fetchPolicyDetail(policyId) {
  try {
    const response = await axios.get(BASE_URL, {
      params: {
        apiKeyNm: API_KEY,
        pageType: '2',  // 상세 조회
        plcyNo: policyId,
        rtnType: 'json'
      },
      timeout: 10000
    });

    if (response.data.resultCode !== 200) {
      console.log(`   ⚠️  ${policyId}: API 오류 (${response.data.resultMessage})`);
      return null;
    }

    // 상세 정보는 result.youthPolicyList[0]에 있음
    const detail = response.data.result?.youthPolicyList?.[0];
    
    if (!detail) {
      console.log(`   ⚠️  ${policyId}: 상세 정보 없음`);
      return null;
    }

    return detail;
  } catch (error) {
    console.log(`   ❌ ${policyId}: ${error.message}`);
    return null;
  }
}

/**
 * DB에 상세 정보 업데이트
 */
async function updatePolicyDetail(policyId, detail) {
  const query = `
    UPDATE policies SET
      -- 지원 내용 (AI 요약에 필수)
      content = COALESCE($2, content),
      plcysprtcn = $2,
      
      -- 신청 방법
      plcyaplymthdcn = $3,
      
      -- 선정 방법
      srngmthdcn = $4,
      
      -- 제출 서류
      sbmsndcmntcn = $5,
      
      -- 기타 사항
      etcmttrcn = $6,
      
      -- 참고 URL
      refurladdr1 = $7,
      refurladdr2 = $8,
      
      -- 신청 URL
      aplyurladdr = COALESCE($9, aplyurladdr),
      application_url = COALESCE($9, application_url),
      
      -- 운영/주관 기관
      operinstcdnm = $10,
      sprvsninstcdnm = $11,
      rgtrinstcdnm = $12,
      
      -- 담당자 정보
      operinstpicnm = $13,
      sprvsninstpicnm = $14,
      
      -- 연령 정보
      sprttrgtminage = $15,
      sprttrgtmaxage = $16,
      
      -- 사업 기간
      bizprdbgngymd = $17,
      bizprdendymd = $18,
      
      -- 상세 정보 업데이트 시간
      updated_at = CURRENT_TIMESTAMP
    WHERE id = $1
  `;

  const values = [
    policyId,
    detail.plcySprtCn || null,           // 지원내용
    detail.plcyAplyMthdCn || null,       // 신청방법
    detail.srngMthdCn || null,           // 선정방법
    detail.sbmsnDcmntCn || null,         // 제출서류
    detail.etcMttrCn || null,            // 기타사항
    detail.refUrlAddr1 || null,          // 참고URL1
    detail.refUrlAddr2 || null,          // 참고URL2
    detail.aplyUrlAddr || null,          // 신청URL
    detail.operInstCdNm || null,         // 운영기관명
    detail.sprvsnInstCdNm || null,       // 주관기관명
    detail.rgtrInstCdNm || null,         // 등록기관명
    detail.operInstPicNm || null,        // 운영기관 담당자
    detail.sprvsnInstPicNm || null,      // 주관기관 담당자
    detail.sprtTrgtMinAge || null,       // 최소연령
    detail.sprtTrgtMaxAge || null,       // 최대연령
    detail.bizPrdBgngYmd || null,        // 사업시작일
    detail.bizPrdEndYmd || null          // 사업종료일
  ];

  await db.query(query, values);
}

/**
 * 상세 정보가 없는 정책 목록 조회
 */
async function getPoliciesWithoutDetails(limit = BATCH_SIZE) {
  const query = `
    SELECT id, title
    FROM policies
    WHERE status = 'active'
      AND (plcysprtcn IS NULL OR plcysprtcn = '' OR content IS NULL OR content = '')
    ORDER BY updated_at DESC
    LIMIT $1
  `;
  
  const result = await db.query(query, [limit]);
  return result.rows;
}

/**
 * 모든 정책 목록 조회 (전체 업데이트용)
 */
async function getAllPolicies(offset = 0, limit = BATCH_SIZE) {
  const query = `
    SELECT id, title
    FROM policies
    WHERE status = 'active'
    ORDER BY updated_at DESC
    LIMIT $1 OFFSET $2
  `;
  
  const result = await db.query(query, [limit, offset]);
  return result.rows;
}

/**
 * 메인 동기화 함수
 */
async function syncPolicyDetails(options = {}) {
  const { onlyMissing = true, maxPolicies = 1000 } = options;
  
  console.log('🚀 정책 상세 정보 동기화 시작...\n');
  console.log(`   모드: ${onlyMissing ? '상세정보 없는 정책만' : '전체 정책'}`);
  console.log(`   최대 처리: ${maxPolicies}개\n`);

  let totalProcessed = 0;
  let totalUpdated = 0;
  let totalFailed = 0;
  let offset = 0;

  try {
    while (totalProcessed < maxPolicies) {
      // 정책 목록 가져오기
      let policies;
      if (onlyMissing) {
        policies = await getPoliciesWithoutDetails(BATCH_SIZE);
      } else {
        policies = await getAllPolicies(offset, BATCH_SIZE);
        offset += BATCH_SIZE;
      }

      if (policies.length === 0) {
        console.log('\n✅ 처리할 정책이 더 이상 없습니다.');
        break;
      }

      console.log(`📦 배치 처리 중... (${totalProcessed + 1} ~ ${totalProcessed + policies.length})`);

      for (const policy of policies) {
        if (totalProcessed >= maxPolicies) break;

        // 상세 정보 가져오기
        const detail = await fetchPolicyDetail(policy.id);
        
        if (detail) {
          // DB 업데이트
          await updatePolicyDetail(policy.id, detail);
          
          const hasContent = detail.plcySprtCn && detail.plcySprtCn.length > 0;
          console.log(`   ✅ ${policy.id}: ${policy.title.substring(0, 30)}... ${hasContent ? '(상세정보 있음)' : '(상세정보 없음)'}`);
          totalUpdated++;
        } else {
          totalFailed++;
        }

        totalProcessed++;

        // API 부하 방지
        await new Promise(resolve => setTimeout(resolve, API_DELAY));
      }

      console.log(`   → 진행률: ${totalProcessed}개 처리 (성공: ${totalUpdated}, 실패: ${totalFailed})\n`);
    }

    console.log('\n🎉 동기화 완료!');
    console.log(`   총 처리: ${totalProcessed}개`);
    console.log(`   성공: ${totalUpdated}개`);
    console.log(`   실패: ${totalFailed}개`);

  } catch (error) {
    console.error('\n❌ 동기화 중 오류 발생:', error);
    throw error;
  }
}

/**
 * 특정 정책 상세 정보 동기화 (단건)
 */
async function syncSinglePolicy(policyId) {
  console.log(`🔍 정책 ${policyId} 상세 정보 동기화 중...`);
  
  const detail = await fetchPolicyDetail(policyId);
  
  if (detail) {
    await updatePolicyDetail(policyId, detail);
    console.log('✅ 동기화 완료!');
    console.log(`   지원내용: ${detail.plcySprtCn ? '있음' : '없음'}`);
    console.log(`   신청방법: ${detail.plcyAplyMthdCn ? '있음' : '없음'}`);
    console.log(`   제출서류: ${detail.sbmsnDcmntCn ? '있음' : '없음'}`);
    return true;
  } else {
    console.log('❌ 상세 정보를 가져오지 못했습니다.');
    return false;
  }
}

// CLI 실행
async function main() {
  const args = process.argv.slice(2);
  
  try {
    if (args[0] === '--single' && args[1]) {
      // 단건 동기화
      await syncSinglePolicy(args[1]);
    } else if (args[0] === '--all') {
      // 전체 정책 동기화
      const maxPolicies = parseInt(args[1]) || 1000;
      await syncPolicyDetails({ onlyMissing: false, maxPolicies });
    } else {
      // 기본: 상세정보 없는 정책만
      const maxPolicies = parseInt(args[0]) || 500;
      await syncPolicyDetails({ onlyMissing: true, maxPolicies });
    }
    
    process.exit(0);
  } catch (error) {
    console.error('❌ 실행 오류:', error);
    process.exit(1);
  }
}

// 사용법 출력
if (process.argv.includes('--help')) {
  console.log(`
정책 상세 정보 동기화 스크립트

사용법:
  node syncPolicyDetails.js              # 상세정보 없는 정책 500개 동기화
  node syncPolicyDetails.js 100          # 상세정보 없는 정책 100개 동기화
  node syncPolicyDetails.js --all        # 전체 정책 상세정보 동기화 (최대 1000개)
  node syncPolicyDetails.js --all 200    # 전체 정책 200개 동기화
  node syncPolicyDetails.js --single <정책ID>  # 특정 정책 1개 동기화

예시:
  node syncPolicyDetails.js --single R2024010100001
`);
  process.exit(0);
}

if (require.main === module) {
  main();
}

module.exports = { syncPolicyDetails, syncSinglePolicy, fetchPolicyDetail };

