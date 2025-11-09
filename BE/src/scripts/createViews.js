#!/usr/bin/env node

require('dotenv').config();
const db = require('../config/database');
const ontongService = require('../services/ontongService');

async function createViews() {
  console.log('🔧 데이터베이스 뷰 생성 중...\n');

  try {
    // 1. popular_policies 뷰 생성
    console.log('📊 popular_policies 뷰 생성 중...');

    // 기존 뷰 삭제
    await db.query('DROP VIEW IF EXISTS popular_policies CASCADE');

    // 새 뷰 생성 - ontongService의 변환 로직과 동일한 형식으로
    await db.query(`
      CREATE VIEW popular_policies AS
      SELECT
        p.id,
        p.title as "plcyNm",
        p.category as "bscPlanPlcyWayNoNm",
        p.description as "plcyExplnCn",
        COALESCE(
          (p.region::jsonb->0)::text,
          '전국'
        ) as "rgtrupInstCdNm",
        CASE
          WHEN p.deadline IS NULL THEN '상시'
          ELSE '기간 지정'
        END as "aplyPrdSeCd",
        TO_CHAR(p.deadline, 'YYYYMMDD') as "aplyPrdEndYmd",
        TO_CHAR(p.start_date, 'YYYYMMDD') as "bizPrdBgngYmd",
        TO_CHAR(p.end_date, 'YYYYMMDD') as "bizPrdEndYmd",
        p.application_url as "applicationUrl",
        p.requirements,
        COALESCE(p.view_count, 0) as saves,
        false as "isBookmarked"
      FROM policies p
      WHERE p.status = 'active'
      ORDER BY
        COALESCE(p.popularity_score, 0) DESC,
        COALESCE(p.view_count, 0) DESC,
        p.updated_at DESC
    `);

    console.log('✅ popular_policies 뷰 생성 완료\n');

    // 2. deadline_approaching_policies 뷰 생성
    console.log('📊 deadline_approaching_policies 뷰 생성 중...');

    // 기존 뷰 삭제
    await db.query('DROP VIEW IF EXISTS deadline_approaching_policies CASCADE');

    // 새 뷰 생성
    await db.query(`
      CREATE VIEW deadline_approaching_policies AS
      SELECT
        p.id,
        p.title as "plcyNm",
        p.category as "bscPlanPlcyWayNoNm",
        p.description as "plcyExplnCn",
        COALESCE(
          (p.region::jsonb->0)::text,
          '전국'
        ) as "rgtrupInstCdNm",
        CASE
          WHEN p.deadline IS NULL THEN '상시'
          ELSE '기간 지정'
        END as "aplyPrdSeCd",
        TO_CHAR(p.deadline, 'YYYYMMDD') as "aplyPrdEndYmd",
        TO_CHAR(p.start_date, 'YYYYMMDD') as "bizPrdBgngYmd",
        TO_CHAR(p.end_date, 'YYYYMMDD') as "bizPrdEndYmd",
        p.application_url as "applicationUrl",
        p.requirements,
        COALESCE(p.view_count, 0) as saves,
        false as "isBookmarked"
      FROM policies p
      WHERE p.status = 'active'
        AND p.end_date IS NOT NULL
      ORDER BY p.end_date ASC
    `);

    console.log('✅ deadline_approaching_policies 뷰 생성 완료\n');

    // 뷰 확인
    console.log('🔍 생성된 뷰 확인 중...');
    const views = await db.query(`
      SELECT table_name
      FROM information_schema.views
      WHERE table_schema = 'public'
        AND table_name IN ('popular_policies', 'deadline_approaching_policies')
      ORDER BY table_name
    `);

    console.log(`✅ 총 ${views.rows.length}개의 뷰가 생성되었습니다:`);
    views.rows.forEach(row => {
      console.log(`   - ${row.table_name}`);
    });

    // 뷰 데이터 확인
    console.log('\n📊 뷰 데이터 샘플:');

    const popularSample = await db.query('SELECT COUNT(*) as count FROM popular_policies');
    console.log(`   popular_policies: ${popularSample.rows[0].count}개 정책`);

    const deadlineSample = await db.query('SELECT COUNT(*) as count FROM deadline_approaching_policies');
    console.log(`   deadline_approaching_policies: ${deadlineSample.rows[0].count}개 정책`);

    console.log('\n🎉 뷰 생성 완료!');

  } catch (error) {
    console.error('❌ 뷰 생성 실패:', error);
    throw error;
  } finally {
    process.exit(0);
  }
}

createViews();
