#!/usr/bin/env node

const axios = require('axios');
const db = require('../config/database');
require('dotenv').config();

async function syncPolicies() {
  console.log('🚀 정책 동기화 시작...\n');

  const apiKey = process.env.ONTONG_API_KEY;
  let totalInserted = 0;
  let totalUpdated = 0;
  let pageNum = 1;
  const pageSize = 100;

  try {
    while (true) {
      console.log(`📄 페이지 ${pageNum} 가져오는 중...`);

      const response = await axios.get('https://www.youthcenter.go.kr/go/ythip/getPlcy', {
        params: {
          apiKeyNm: apiKey,
          pageNum,
          pageSize,
          rtnType: 'json'
        },
        timeout: 30000
      });

      if (response.data.resultCode !== 200) {
        console.error(`❌ API 오류: ${response.data.resultMessage}`);
        break;
      }

      const policies = response.data.result.youthPolicyList;
      if (!policies || policies.length === 0) {
        console.log('✅ 모든 정책 동기화 완료!');
        break;
      }

      console.log(`   ${policies.length}개 정책 처리 중...`);

      for (const policy of policies) {
        try {
          // 정책이 이미 존재하는지 확인
          const existingPolicy = await db.query(
            'SELECT id FROM policies WHERE id = $1',
            [policy.plcyNo]
          );

          if (existingPolicy.rows.length > 0) {
            // 업데이트
            await db.query(`
              UPDATE policies SET
                title = $2,
                category = $3,
                description = $4,
                content = $5,
                deadline = $6,
                start_date = $7,
                end_date = $8,
                application_url = $9,
                contact_info = $10,
                requirements = $11,
                benefits = $12,
                region = $13,
                target_age = $14,
                mclsfnm = $15,
                plcypvsnmthdcd = $16,
                mrgsttscd = $17,
                jobcd = $18,
                schoolcd = $19,
                plcymajorcd = $20,
                earncndsecd = $21,
                addaplyqlfccndcn = $22,
                status = 'active',
                cached_at = CURRENT_TIMESTAMP,
                updated_at = CURRENT_TIMESTAMP
              WHERE id = $1
            `, [
              policy.plcyNo,
              policy.plcyNm,
              policy.lclsfNm,
              policy.plcyExplnCn,
              policy.plcySprtCn,
              null,
              parseBizDate(policy.bizPrdBgngYmd),
              parseBizDate(policy.bizPrdEndYmd),
              policy.refUrlAddr1 || policy.aplyUrlAddr,
              JSON.stringify({
                supervisor: policy.sprvsnInstCdNm,
                operator: policy.operInstCdNm,
                pic: policy.sprvsnInstPicNm
              }),
              JSON.stringify([policy.addAplyQlfcCndCn || '']),
              JSON.stringify([policy.plcySprtCn || '']),
              JSON.stringify([policy.rgtrInstCdNm || '전국']),
              JSON.stringify({
                min: parseInt(policy.sprtTrgtMinAge) || 18,
                max: parseInt(policy.sprtTrgtMaxAge) || 34
              }),
              policy.mclsfNm,
              policy.plcyPvsnMthdCd,
              policy.mrgSttsCd,
              policy.jobCd,
              policy.schoolCd,
              policy.plcyMajorCd,
              policy.earnCndSeCd,
              policy.addAplyQlfcCndCn
            ]);
            totalUpdated++;
          } else {
            // 신규 삽입
            await db.query(`
              INSERT INTO policies (
                id, title, category, description, content, deadline,
                start_date, end_date, application_url, contact_info,
                requirements, benefits, region, target_age,
                mclsfnm, plcypvsnmthdcd, mrgsttscd, jobcd, schoolcd,
                plcymajorcd, earncndsecd, addaplyqlfccndcn,
                status, cached_at, updated_at
              ) VALUES (
                $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14,
                $15, $16, $17, $18, $19, $20, $21, $22,
                'active', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
              )
            `, [
              policy.plcyNo,
              policy.plcyNm,
              policy.lclsfNm,
              policy.plcyExplnCn,
              policy.plcySprtCn,
              null,
              parseBizDate(policy.bizPrdBgngYmd),
              parseBizDate(policy.bizPrdEndYmd),
              policy.refUrlAddr1 || policy.aplyUrlAddr,
              JSON.stringify({
                supervisor: policy.sprvsnInstCdNm,
                operator: policy.operInstCdNm,
                pic: policy.sprvsnInstPicNm
              }),
              JSON.stringify([policy.addAplyQlfcCndCn || '']),
              JSON.stringify([policy.plcySprtCn || '']),
              JSON.stringify([policy.rgtrInstCdNm || '전국']),
              JSON.stringify({
                min: parseInt(policy.sprtTrgtMinAge) || 18,
                max: parseInt(policy.sprtTrgtMaxAge) || 34
              }),
              policy.mclsfNm,
              policy.plcyPvsnMthdCd,
              policy.mrgSttsCd,
              policy.jobCd,
              policy.schoolCd,
              policy.plcyMajorCd,
              policy.earnCndSeCd,
              policy.addAplyQlfcCndCn
            ]);
            totalInserted++;
          }
        } catch (error) {
          console.error(`   ⚠️  정책 ${policy.plcyNo} 처리 실패:`, error.message);
        }
      }

      console.log(`   ✅ 페이지 ${pageNum} 완료 (신규: ${totalInserted}, 업데이트: ${totalUpdated})\n`);

      // 다음 페이지
      pageNum++;

      // 마지막 페이지 체크
      const totalCount = response.data.result.pagging.totCount;
      if (pageNum > Math.ceil(totalCount / pageSize)) {
        break;
      }

      // API 부하 방지
      await new Promise(resolve => setTimeout(resolve, 500));
    }

    console.log(`\n🎉 동기화 완료!`);
    console.log(`   총 처리: ${totalInserted + totalUpdated}개`);
    console.log(`   신규: ${totalInserted}개`);
    console.log(`   업데이트: ${totalUpdated}개`);

  } catch (error) {
    console.error('❌ 동기화 실패:', error);
  } finally {
    process.exit(0);
  }
}

function parseBizDate(dateStr) {
  if (!dateStr || dateStr.length !== 8) return null;
  const year = dateStr.substring(0, 4);
  const month = dateStr.substring(4, 6);
  const day = dateStr.substring(6, 8);
  return `${year}-${month}-${day}`;
}

syncPolicies();
