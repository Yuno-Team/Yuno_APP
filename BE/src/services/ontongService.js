const axios = require('axios');
const db = require('../config/database');

class OntongService {
  constructor() {
    this.apiKey = process.env.ONTONG_API_KEY;
    this.baseURL = process.env.ONTONG_API_BASE_URL || 'https://www.youthcenter.go.kr';
    this.client = axios.create({
      baseURL: this.baseURL,
      timeout: 10000,
      headers: {
        'User-Agent': 'Yuno-Backend/1.0'
      }
    });

    // 요청 인터셉터
    this.client.interceptors.request.use((config) => {
      console.log(`[ONTONG API] ${config.method?.toUpperCase()} ${config.url}`);
      return config;
    });

    // 응답 인터셉터
    this.client.interceptors.response.use(
      (response) => response,
      (error) => {
        console.error('[ONTONG API ERROR]', error.message);
        throw error;
      }
    );
  }

  /**
   * 정책 검색 (프론트엔드 호환 - 온통청년 API 필드명 사용)
   */
  async searchPolicies(params = {}) {
    const {
      page = 1,
      limit = 20,
      searchQuery,
      mainCategory,
      subCategory,
      policyMethodCode,
      maritalStatusCode,
      employmentCode,
      educationCode,
      specialRequirementCode,
      majorCode,
      incomeCode,
      region
    } = params;

    try {
      // 데이터베이스에서 정책 검색
      const result = await this.searchPoliciesFromDB({
        page,
        limit,
        searchQuery,
        mainCategory,
        subCategory,
        policyMethodCode,
        maritalStatusCode,
        employmentCode,
        educationCode,
        specialRequirementCode,
        majorCode,
        incomeCode,
        region
      });

      // 프론트엔드 형식으로 변환
      const transformedPolicies = result.policies.map(policy =>
        this.transformToFrontendFormat(policy)
      );

      return {
        policies: transformedPolicies,
        pagination: result.pagination
      };

    } catch (error) {
      console.error('정책 검색 중 오류:', error);
      return {
        policies: [],
        pagination: { page, limit, total: 0, hasNext: false }
      };
    }
  }

  /**
   * 데이터베이스에서 정책 검색 (필터 파라미터 지원)
   */
  async searchPoliciesFromDB(params) {
    const {
      page = 1,
      limit = 20,
      searchQuery,
      mainCategory,
      subCategory,
      policyMethodCode,
      maritalStatusCode,
      employmentCode,
      educationCode,
      specialRequirementCode,
      majorCode,
      incomeCode,
      region
    } = params;

    const offset = (page - 1) * limit;
    const conditions = ['status = $1'];
    const values = ['active'];
    let paramIndex = 2;

    // 2025년 이후 정책만 필터링
    conditions.push(`EXTRACT(YEAR FROM COALESCE(start_date, updated_at)) >= $${paramIndex}`);
    values.push(2025);
    paramIndex++;

    // 검색어 필터
    if (searchQuery) {
      conditions.push(`(title ILIKE $${paramIndex} OR description ILIKE $${paramIndex})`);
      values.push(`%${searchQuery}%`);
      paramIndex++;
    }

    // 대분류 필터
    if (mainCategory) {
      conditions.push(`category = $${paramIndex}`);
      values.push(mainCategory);
      paramIndex++;
    }

    // 중분류 필터
    if (subCategory) {
      conditions.push(`mclsfnm = $${paramIndex}`);
      values.push(subCategory);
      paramIndex++;
    }

    // 정책제공방법 필터
    if (policyMethodCode) {
      conditions.push(`plcypvsnmthdcd = $${paramIndex}`);
      values.push(policyMethodCode);
      paramIndex++;
    }

    // 결혼상태 필터
    if (maritalStatusCode) {
      conditions.push(`mrgsttscd = $${paramIndex}`);
      values.push(maritalStatusCode);
      paramIndex++;
    }

    // 취업요건 필터
    if (employmentCode) {
      conditions.push(`jobcd = $${paramIndex}`);
      values.push(employmentCode);
      paramIndex++;
    }

    // 학력요건 필터
    if (educationCode) {
      conditions.push(`schoolcd = $${paramIndex}`);
      values.push(educationCode);
      paramIndex++;
    }

    // 특화요건 필터 (addAplyQlfcCndCn 필드에 포함되어 있는지 확인)
    if (specialRequirementCode) {
      conditions.push(`addaplyqlfccndcn ILIKE $${paramIndex}`);
      values.push(`%${specialRequirementCode}%`);
      paramIndex++;
    }

    // 전공요건 필터
    if (majorCode) {
      conditions.push(`plcymajorcd = $${paramIndex}`);
      values.push(majorCode);
      paramIndex++;
    }

    // 소득조건 필터
    if (incomeCode) {
      conditions.push(`earncndsecd = $${paramIndex}`);
      values.push(incomeCode);
      paramIndex++;
    }

    // 지역 필터
    if (region) {
      conditions.push(`(region @> $${paramIndex} OR region @> $${paramIndex + 1})`);
      values.push(JSON.stringify([region]), JSON.stringify(['전국']));
      paramIndex += 2;
    }

    const whereClause = conditions.join(' AND ');

    // 총 개수 조회
    const countQuery = `SELECT COUNT(*) as total FROM policies WHERE ${whereClause}`;
    const countResult = await db.query(countQuery, values);
    const total = parseInt(countResult.rows[0].total);

    // 정책 목록 조회 (모든 필터 코드 필드 포함)
    const query = `
      SELECT id, title, category, description, content, deadline, start_date, end_date,
             application_url, contact_info, requirements, benefits, documents, region,
             target_age, target_education, tags, image_url, status, view_count,
             popularity_score, cached_at, updated_at,
             mclsfnm, plcypvsnmthdcd, mrgsttscd, jobcd, schoolcd,
             plcymajorcd, earncndsecd, addaplyqlfccndcn
      FROM policies
      WHERE ${whereClause}
      ORDER BY popularity_score DESC, updated_at DESC
      LIMIT $${paramIndex} OFFSET $${paramIndex + 1}
    `;

    values.push(limit, offset);
    const result = await db.query(query, values);

    return {
      policies: result.rows.map(row => this.transformToFrontendFormat(row)),
      pagination: {
        page,
        limit,
        total,
        hasNext: offset + limit < total
      }
    };
  }

  /**
   * 데이터베이스 정책을 프론트엔드 형식으로 변환
   * (온통청년 API 필드명 사용)
   */
  transformToFrontendFormat(policy) {
    // 대분류 매핑 (category -> 온통청년 대분류명)
    const categoryToBscPlanMapping = {
      '취업지원': '일자리',
      '주거지원': '주거',
      '장학금': '교육',
      '생활복지': '복지문화',
      '참여권리': '참여권리',
      '창업지원': '일자리',
      '문화': '복지문화'
    };

    // 날짜 포맷 변환 헬퍼 (ISO -> YYYYMMDD)
    const formatDateToYMD = (dateStr) => {
      if (!dateStr) return null;
      try {
        const date = new Date(dateStr);
        return date.toISOString().split('T')[0].replace(/-/g, '');
      } catch (e) {
        return null;
      }
    };

    // 사업 기간 변환
    const bizPrdBgngYmd = formatDateToYMD(policy.start_date);
    const bizPrdEndYmd = formatDateToYMD(policy.end_date);

    // 마감일 포맷 변환
    let aplyPrdEndYmd = bizPrdEndYmd;
    let aplyPrdSeCd = bizPrdEndYmd ? '기간' : '상시';

    // 지역명 추출
    let rgtrupInstCdNm = '전국';
    if (policy.region && Array.isArray(policy.region) && policy.region.length > 0) {
      rgtrupInstCdNm = policy.region[0];
    }

    return {
      id: policy.id,
      plcyNm: policy.title || '',
      bscPlanPlcyWayNoNm: categoryToBscPlanMapping[policy.category] || policy.category || '',
      plcyExplnCn: policy.description || '',
      rgtrupInstCdNm: rgtrupInstCdNm,
      aplyPrdSeCd: aplyPrdSeCd,
      aplyPrdEndYmd: aplyPrdEndYmd,
      applicationUrl: policy.application_url || '',
      requirements: Array.isArray(policy.requirements) ? policy.requirements : [],
      saves: policy.popularity_score || policy.view_count || 0,
      isBookmarked: false,

      // 사업 기간 원본 필드 추가
      bizPrdBgngYmd: bizPrdBgngYmd,  // 사업 시작일
      bizPrdEndYmd: bizPrdEndYmd,    // 사업 종료일

      // 필터 코드 정보 추가
      lclsfNm: categoryToBscPlanMapping[policy.category] || policy.category || '',  // 대분류
      mclsfNm: policy.mclsfnm || '',              // 중분류
      plcyPvsnMthdCd: policy.plcypvsnmthdcd || '', // 정책제공방법 코드
      mrgSttsCd: policy.mrgsttscd || '',          // 결혼상태 코드
      jobCd: policy.jobcd || '',                  // 취업요건 코드
      schoolCd: policy.schoolcd || '',            // 학력 코드
      plcyMajorCd: policy.plcymajorcd || '',      // 전공 코드
      earnCndSeCd: policy.earncndsecd || '',      // 소득조건 코드
      spclRqrmCn: policy.addaplyqlfccndcn || ''   // 특화요건 텍스트
    };
  }

  /**
   * 추천 정책 조회 (관심사 기반)
   */
  async getRecommendedPolicies(params = {}) {
    const { interests = [], limit = 2 } = params;

    try {
      let query;
      let values = ['active'];
      let paramIndex = 2;

      if (interests.length > 0) {
        // 관심사 매핑 (프론트엔드 관심사 -> DB 카테고리)
        const categoryMapping = {
          '창업': '창업지원',
          '취업': '취업지원',
          '주거': '주거지원',
          '교육': '장학금',
          '복지': '생활복지',
          '문화': '문화',
          '참여': '참여권리'
        };

        const categories = interests.map(interest =>
          categoryMapping[interest] || interest
        );

        // 관심사와 일치하는 카테고리로 필터링
        query = `
          SELECT id, title, category, description, content, deadline, start_date, end_date,
                 application_url, contact_info, requirements, benefits, documents, region,
                 target_age, target_education, tags, image_url, status, view_count,
                 popularity_score, cached_at, updated_at
          FROM policies
          WHERE status = $1
            AND category = ANY($${paramIndex})
            AND EXTRACT(YEAR FROM COALESCE(start_date, updated_at)) >= $${paramIndex + 1}
          ORDER BY popularity_score DESC, updated_at DESC
          LIMIT $${paramIndex + 2}
        `;
        values.push(categories, 2025, limit);
      } else {
        // 관심사가 없으면 인기도 순으로 반환
        query = `
          SELECT id, title, category, description, content, deadline, start_date, end_date,
                 application_url, contact_info, requirements, benefits, documents, region,
                 target_age, target_education, tags, image_url, status, view_count,
                 popularity_score, cached_at, updated_at
          FROM policies
          WHERE status = $1
            AND EXTRACT(YEAR FROM COALESCE(start_date, updated_at)) >= $${paramIndex}
          ORDER BY popularity_score DESC, updated_at DESC
          LIMIT $${paramIndex + 1}
        `;
        values.push(2025, limit);
      }

      const result = await db.query(query, values);

      // 프론트엔드 형식으로 변환
      const policies = result.rows.map(policy =>
        this.transformToFrontendFormat(policy)
      );

      return { policies };

    } catch (error) {
      console.error('추천 정책 조회 실패:', error);
      return { policies: [] };
    }
  }

  /**
   * 인기 정책 TOP N 조회
   */
  async getPopularPolicies(params = {}) {
    const { limit = 3 } = params;

    try {
      const query = `
        SELECT id, title, category, description, content, deadline, start_date, end_date,
               application_url, contact_info, requirements, benefits, documents, region,
               target_age, target_education, tags, image_url, status, view_count,
               popularity_score, cached_at, updated_at
        FROM policies
        WHERE status = $1
          AND EXTRACT(YEAR FROM COALESCE(start_date, updated_at)) >= $2
        ORDER BY popularity_score DESC, view_count DESC, updated_at DESC
        LIMIT $3
      `;

      const result = await db.query(query, ['active', 2025, limit]);

      // 프론트엔드 형식으로 변환
      const policies = result.rows.map(policy =>
        this.transformToFrontendFormat(policy)
      );

      return { policies };

    } catch (error) {
      console.error('인기 정책 조회 실패:', error);
      return { policies: [] };
    }
  }

  /**
   * 마감 임박 정책 조회
   */
  async getUpcomingDeadlines(params = {}) {
    const { limit = 3 } = params;

    try {
      const query = `
        SELECT id, title, category, description, content, deadline, start_date, end_date,
               application_url, contact_info, requirements, benefits, documents, region,
               target_age, target_education, tags, image_url, status, view_count,
               popularity_score, cached_at, updated_at
        FROM policies
        WHERE status = $1
          AND end_date IS NOT NULL
          AND end_date > CURRENT_DATE
          AND EXTRACT(YEAR FROM COALESCE(start_date, updated_at)) >= $2
        ORDER BY end_date ASC
        LIMIT $3
      `;

      const result = await db.query(query, ['active', 2025, limit]);

      // 프론트엔드 형식으로 변환
      const policies = result.rows.map(policy =>
        this.transformToFrontendFormat(policy)
      );

      return { policies };

    } catch (error) {
      console.error('마감 임박 정책 조회 실패:', error);
      return { policies: [] };
    }
  }

  /**
   * 정책 목록 조회 (데이터베이스 캐시 우선, API는 갱신시에만)
   */
  async getPolicies(params = {}) {
    const {
      page = 1,
      limit = 20,
      category,
      region,
      searchText,
      ageMin,
      ageMax
    } = params;

    try {
      // 1단계: 데이터베이스에서 조회
      const dbResult = await this.getPoliciesFromDB(params);

      // 데이터가 충분하고 최신이면 반환
      if (dbResult.policies.length > 0 && this.isDataFresh(dbResult.lastCached)) {
        console.log(`[DB] 정책 조회 성공: ${dbResult.policies.length}개 (페이지 ${page})`);
        return dbResult;
      }

      // 2단계: 데이터가 부족하거나 오래된 경우 API 호출 후 캐시 업데이트
      console.log('[API] 정책 데이터 갱신 필요, 온통청년 API 호출...');

      try {
        const apiResult = await this.getPoliciesFromAPI(params);

        // API 데이터를 데이터베이스에 저장 (백그라운드)
        this.updateCacheInBackground(apiResult.policies, category);

        return apiResult;
      } catch (apiError) {
        console.error('온통청년 API 호출 실패, 캐시된 데이터 반환:', apiError.message);

        // API 실패시 오래된 캐시라도 반환
        return dbResult.policies.length > 0 ? dbResult : {
          policies: [],
          pagination: { page, limit, total: 0, hasNext: false }
        };
      }

    } catch (error) {
      console.error('정책 조회 중 오류:', error);

      // 모든 것이 실패하면 빈 결과 반환
      return {
        policies: [],
        pagination: { page, limit, total: 0, hasNext: false }
      };
    }
  }

  /**
   * 데이터베이스에서 정책 조회
   */
  async getPoliciesFromDB(params) {
    const {
      page = 1,
      limit = 20,
      category,
      region,
      searchText,
      ageMin,
      ageMax
    } = params;

    const offset = (page - 1) * limit;
    const conditions = ['status = $1'];
    const values = ['active'];
    let paramIndex = 2;

    // 2025년 이후 정책만 필터링
    conditions.push(`EXTRACT(YEAR FROM COALESCE(start_date, updated_at)) >= $${paramIndex}`);
    values.push(2025);
    paramIndex++;

    // 조건 추가
    if (category) {
      conditions.push(`category = $${paramIndex}`);
      values.push(category);
      paramIndex++;
    }

    if (searchText) {
      conditions.push(`(title ILIKE $${paramIndex} OR description ILIKE $${paramIndex})`);
      values.push(`%${searchText}%`);
      paramIndex++;
    }

    if (region) {
      conditions.push(`region @> $${paramIndex}`);
      values.push(JSON.stringify([region]));
      paramIndex++;
    }

    if (ageMin || ageMax) {
      if (ageMin && ageMax) {
        conditions.push(`(target_age->>'min')::int <= $${paramIndex} AND (target_age->>'max')::int >= $${paramIndex + 1}`);
        values.push(ageMax, ageMin);
        paramIndex += 2;
      } else if (ageMin) {
        conditions.push(`(target_age->>'max')::int >= $${paramIndex}`);
        values.push(ageMin);
        paramIndex++;
      } else if (ageMax) {
        conditions.push(`(target_age->>'min')::int <= $${paramIndex}`);
        values.push(ageMax);
        paramIndex++;
      }
    }

    const whereClause = conditions.join(' AND ');

    // 총 개수 조회
    const countQuery = `SELECT COUNT(*) as total FROM policies WHERE ${whereClause}`;
    const countResult = await db.query(countQuery, values);
    const total = parseInt(countResult.rows[0].total);

    // 정책 목록 조회
    const query = `
      SELECT id, title, category, description, content, deadline, start_date, end_date,
             application_url, contact_info, requirements, benefits, documents, region,
             target_age, target_education, tags, image_url, status, view_count,
             popularity_score, cached_at, updated_at,
             mclsfnm, plcypvsnmthdcd, mrgsttscd, jobcd, schoolcd,
             plcymajorcd, earncndsecd, addaplyqlfccndcn
      FROM policies
      WHERE ${whereClause}
      ORDER BY popularity_score DESC, updated_at DESC
      LIMIT $${paramIndex} OFFSET $${paramIndex + 1}
    `;

    values.push(limit, offset);
    const result = await db.query(query, values);

    return {
      policies: result.rows.map(row => this.transformToFrontendFormat(row)),
      pagination: {
        page,
        limit,
        total,
        hasNext: offset + limit < total
      },
      lastCached: result.rows.length > 0 ? result.rows[0].cached_at : null
    };
  }

  /**
   * 온통청년 API에서 정책 조회 (기존 방식)
   */
  async getPoliciesFromAPI(params) {
    const {
      page = 1,
      limit = 20,
      category,
      region,
      searchText,
      ageMin,
      ageMax
    } = params;

    // 온통청년 API 파라미터 구성 (2025년 신규 API)
    const apiParams = {
      apiKeyNm: this.apiKey,
      pageSize: limit,
      pageNum: page,
      pageType: '1',  // 목록 조회
      rtnType: 'json',
      ...(category && { lclsfNm: category }),
      ...(region && { zipCd: region }),
      ...(searchText && { plcyNm: searchText })
    };

    const response = await this.client.get('/go/ythip/getPlcy', {
      params: apiParams
    });

    const policies = this.transformPolicies(response.data);

    // 나이 필터링 (클라이언트 사이드)
    let filteredPolicies = policies;
    if (ageMin || ageMax) {
      filteredPolicies = policies.filter(policy => {
        if (!policy.target_age) return true;

        const policyAgeMin = policy.target_age.min || 0;
        const policyAgeMax = policy.target_age.max || 100;

        if (ageMin && ageMax) {
          return !(policyAgeMax < ageMin || policyAgeMin > ageMax);
        } else if (ageMin) {
          return policyAgeMax >= ageMin;
        } else if (ageMax) {
          return policyAgeMin <= ageMax;
        }

        return true;
      });
    }

    return {
      policies: filteredPolicies,
      pagination: {
        page,
        limit,
        total: response.data.result?.pagging?.totCount || response.data.totalCount || 0,
        hasNext: filteredPolicies.length === limit
      }
    };
  }

  /**
   * 데이터 신선도 확인 (6시간 이내면 신선함)
   */
  isDataFresh(cachedAt) {
    if (!cachedAt) return false;

    const now = new Date();
    const cached = new Date(cachedAt);
    const hoursDiff = (now - cached) / (1000 * 60 * 60);

    return hoursDiff < 6; // 6시간 이내면 신선함
  }

  /**
   * 데이터베이스 정책을 API 형식으로 변환
   */
  transformDBPolicy(row) {
    return {
      id: row.id,
      title: row.title,
      category: row.category,
      description: row.description,
      content: row.content,
      deadline: row.deadline,
      applicationPeriod: this.formatDateRange(row.start_date, row.end_date),
      applicationUrl: row.application_url,
      contactInfo: row.contact_info,
      requirements: row.requirements,
      benefits: row.benefits,
      documents: row.documents,
      region: row.region,
      targetAge: row.target_age,
      targetEducation: row.target_education,
      tags: row.tags,
      imageUrl: row.image_url,
      status: row.status,
      viewCount: row.view_count || 0,
      popularityScore: parseFloat(row.popularity_score) || 0,
      updatedAt: row.updated_at
    };
  }

  /**
   * 날짜 범위 포맷팅
   */
  formatDateRange(startDate, endDate) {
    if (!startDate && !endDate) return '-';

    const formatDate = (date) => {
      if (!date) return '';
      return new Date(date).toLocaleDateString('ko-KR');
    };

    const start = formatDate(startDate);
    const end = formatDate(endDate);

    if (start && end) {
      return `${start} ~ ${end}`;
    } else if (start) {
      return `${start} ~`;
    } else if (end) {
      return `~ ${end}`;
    }

    return '-';
  }

  /**
   * 백그라운드에서 캐시 업데이트
   */
  updateCacheInBackground(policies, category) {
    // 비동기로 처리하여 응답 지연 방지
    setImmediate(async () => {
      try {
        console.log(`[CACHE] 백그라운드 캐시 업데이트 시작: ${policies.length}개 정책`);

        for (const policy of policies) {
          await this.upsertPolicyToCache(policy);
        }

        console.log(`[CACHE] 백그라운드 캐시 업데이트 완료`);
      } catch (error) {
        console.error('[CACHE] 백그라운드 캐시 업데이트 실패:', error);
      }
    });
  }

  /**
   * 단일 정책을 캐시에 저장/업데이트
   */
  async upsertPolicyToCache(policy) {
    const checkQuery = 'SELECT id FROM policies WHERE id = $1';
    const existing = await db.query(checkQuery, [policy.id]);

    if (existing.rows.length > 0) {
      // 업데이트
      const updateQuery = `
        UPDATE policies SET
          title = $2, category = $3, description = $4, content = $5,
          deadline = $6, start_date = $7, end_date = $8, application_url = $9,
          contact_info = $10, requirements = $11, benefits = $12, documents = $13,
          region = $14, target_age = $15, target_education = $16, tags = $17,
          image_url = $18, status = $19, cached_at = CURRENT_TIMESTAMP, updated_at = CURRENT_TIMESTAMP
        WHERE id = $1
      `;

      await db.query(updateQuery, [
        policy.id, policy.title, policy.category, policy.description, policy.content,
        policy.deadline, policy.startDate, policy.endDate, policy.applicationUrl,
        JSON.stringify(policy.contactInfo), JSON.stringify(policy.requirements),
        JSON.stringify(policy.benefits), JSON.stringify(policy.documents),
        JSON.stringify(policy.region), JSON.stringify(policy.targetAge),
        JSON.stringify(policy.targetEducation), JSON.stringify(policy.tags),
        policy.imageUrl, 'active'
      ]);
    } else {
      // 삽입
      const insertQuery = `
        INSERT INTO policies (
          id, title, category, description, content, deadline, start_date, end_date,
          application_url, contact_info, requirements, benefits, documents, region,
          target_age, target_education, tags, image_url, status, cached_at, updated_at
        ) VALUES (
          $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19,
          CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
        )
      `;

      await db.query(insertQuery, [
        policy.id, policy.title, policy.category, policy.description, policy.content,
        policy.deadline, policy.startDate, policy.endDate, policy.applicationUrl,
        JSON.stringify(policy.contactInfo), JSON.stringify(policy.requirements),
        JSON.stringify(policy.benefits), JSON.stringify(policy.documents),
        JSON.stringify(policy.region), JSON.stringify(policy.targetAge),
        JSON.stringify(policy.targetEducation), JSON.stringify(policy.tags),
        policy.imageUrl, 'active'
      ]);
    }
  }

  /**
   * 정책 상세 조회
   */
  async getPolicyDetail(policyId) {
    try {
      const response = await this.client.get('/go/ythip/getPlcy', {
        params: {
          apiKeyNm: this.apiKey,
          pageType: '2',
          plcyNo: policyId,
          rtnType: 'json'
        }
      });

      return this.transformPolicyDetail(response.data);

    } catch (error) {
      console.error('정책 상세 조회 실패:', error);

      // 캐시에서 상세 정보 조회
      const result = await db.query(
        'SELECT * FROM policies WHERE id = $1',
        [policyId]
      );

      if (!result.rows[0]) return null;

      // DB 정책을 프론트엔드 형식으로 변환
      return this.transformToFrontendFormat(result.rows[0]);
    }
  }

  /**
   * 정책 데이터를 로컬 DB에 동기화
   */
  async syncPolicies() {
    try {
      console.log('정책 동기화 시작...');

      let page = 1;
      let totalSynced = 0;
      const limit = 100;

      while (true) {
        const data = await this.getPolicies({ page, limit });

        if (!data.policies || data.policies.length === 0) {
          break;
        }

        // 배치로 데이터베이스에 저장
        await this.savePoliciesBatch(data.policies);
        totalSynced += data.policies.length;

        console.log(`${totalSynced}개 정책 동기화 완료`);

        if (data.policies.length < limit) {
          break;
        }

        page++;

        // API 호출 제한을 고려한 딜레이
        await this.delay(1000);
      }

      console.log(`정책 동기화 완료: 총 ${totalSynced}개`);
      return totalSynced;

    } catch (error) {
      console.error('정책 동기화 실패:', error);
      throw error;
    }
  }

  /**
   * 온통청년 데이터를 내부 포맷으로 변환 (모든 필드 포함)
   */
  transformPolicies(data) {
    // 2025년 신규 API 응답 구조: result.youthPolicyList
    const policyList = data.result?.youthPolicyList || data.youthPolicyList || [];
    if (policyList.length === 0) return [];

    return policyList.map(item => ({
      // 기본 필드 (새 API 필드명으로 변경)
      id: item.plcyNo,
      title: item.plcyNm,
      category: item.lclsfNm,
      description: item.plcyExplnCn,
      content: item.plcySprtCn,
      deadline: this.parseDate(item.aplyYmd),
      start_date: item.bizPrdBgngYmd ? new Date(item.bizPrdBgngYmd) : null,
      end_date: item.bizPrdEndYmd ? new Date(item.bizPrdEndYmd) : null,
      application_url: item.aplyUrlAddr,
      requirements: this.parseRequirements(item.addAplyQlfcCndCn),
      region: item.zipCd,
      target_age: {
        min: item.sprtTrgtMinAge ? parseInt(item.sprtTrgtMinAge) : null,
        max: item.sprtTrgtMaxAge ? parseInt(item.sprtTrgtMaxAge) : null
      },
      tags: this.parseTags(item.plcyKywdNm),
      cached_at: new Date(),

      // 2025년 신규 API 전체 60개 필드
      plcyNo: item.plcyNo,
      plcyNm: item.plcyNm,
      plcyExplnCn: item.plcyExplnCn,
      plcyKywdNm: item.plcyKywdNm,
      lclsfNm: item.lclsfNm,
      mclsfNm: item.mclsfNm,
      plcySprtCn: item.plcySprtCn,
      bscPlanCycl: item.bscPlanCycl,
      bscPlanPlcyWayNo: item.bscPlanPlcyWayNo,
      bscPlanFcsAsmtNo: item.bscPlanFcsAsmtNo,
      bscPlanAsmtNo: item.bscPlanAsmtNo,
      pvsnInstGroupCd: item.pvsnInstGroupCd,
      plcyPvsnMthdCd: item.plcyPvsnMthdCd,
      plcyAprvSttsCd: item.plcyAprvSttsCd,
      sprvsnInstCd: item.sprvsnInstCd,
      sprvsnInstCdNm: item.sprvsnInstCdNm,
      sprvsnInstPicNm: item.sprvsnInstPicNm,
      operInstCd: item.operInstCd,
      operInstCdNm: item.operInstCdNm,
      operInstPicNm: item.operInstPicNm,
      sprtSclLmtYn: item.sprtSclLmtYn,
      aplyPrdSeCd: item.aplyPrdSeCd,
      bizPrdSeCd: item.bizPrdSeCd,
      bizPrdBgngYmd: item.bizPrdBgngYmd,
      bizPrdEndYmd: item.bizPrdEndYmd,
      bizPrdEtcCn: item.bizPrdEtcCn,
      plcyAplyMthdCn: item.plcyAplyMthdCn,
      srngMthdCn: item.srngMthdCn,
      aplyUrlAddr: item.aplyUrlAddr,
      sbmsnDcmntCn: item.sbmsnDcmntCn,
      etcMttrCn: item.etcMttrCn,
      refUrlAddr1: item.refUrlAddr1,
      refUrlAddr2: item.refUrlAddr2,
      sprtSclCnt: item.sprtSclCnt,
      sprtArvlSeqYn: item.sprtArvlSeqYn,
      sprtTrgtMinAge: item.sprtTrgtMinAge,
      sprtTrgtMaxAge: item.sprtTrgtMaxAge,
      sprtTrgtAgeLmtYn: item.sprtTrgtAgeLmtYn,
      mrgSttsCd: item.mrgSttsCd,
      earnCndSeCd: item.earnCndSeCd,
      earnMinAmt: item.earnMinAmt,
      earnMaxAmt: item.earnMaxAmt,
      earnEtcCn: item.earnEtcCn,
      addAplyQlfcCndCn: item.addAplyQlfcCndCn,
      ptcpPrpTrgtCn: item.ptcpPrpTrgtCn,
      inqCnt: item.inqCnt,
      rgtrInstCd: item.rgtrInstCd,
      rgtrInstCdNm: item.rgtrInstCdNm,
      rgtrUpInstCd: item.rgtrUpInstCd,
      rgtrUpInstCdNm: item.rgtrUpInstCdNm,
      rgtrHghrkInstCd: item.rgtrHghrkInstCd,
      rgtrHghrkInstCdNm: item.rgtrHghrkInstCdNm,
      zipCd: item.zipCd,
      plcyMajorCd: item.plcyMajorCd,
      jobCd: item.jobCd,
      schoolCd: item.schoolCd,
      aplyYmd: item.aplyYmd,
      frstRegDt: item.frstRegDt,
      lastMdfcnDt: item.lastMdfcnDt,
      sbizCd: item.sbizCd,

      // 원본 데이터 보관
      raw_data: item
    }));
  }

  /**
   * 정책 상세 데이터 변환
   */
  transformPolicyDetail(data) {
    const detail = data.youthPolicyDetail;

    return {
      ...this.transformPolicies({ youthPolicy: [detail] })[0],
      contact_info: {
        department: detail.cnsgNmor,
        phone: detail.tintCherCn,
        email: detail.cherCtpcCn
      },
      benefits: this.parseBenefits(detail.sporCn),
      documents: this.parseDocuments(detail.pstnPaprCn)
    };
  }

  /**
   * 배치로 정책 데이터 저장 (2025 API 전체 60개 필드 포함)
   */
  async savePoliciesBatch(policies) {
    for (const policy of policies) {
      const query = `
        INSERT INTO policies (
          id, title, category, description, content,
          deadline, start_date, end_date, application_url,
          requirements, region, target_age, tags, cached_at,
          plcyno, plcynm, plcyexplncn, plcykywdnm,
          lclsfnm, mclsfnm, plcysprtcn,
          bscplancycl, bscplanplcywayno, bscplanfcsasmtno, bscplanasmtno,
          pvsninstgroupcd, plcypvsnmthdcd, plcyaprvsttscd,
          sprvsninstcd, sprvsninstcdnm, sprvsninstpicnm,
          operinstcd, operinstcdnm, operinstpicnm,
          sprtscllmtyn, aplyprdsecd, bizprdsecd,
          bizprdbgngymd, bizprdendymd, bizprdetccn,
          plcyaplymthdcn, srngmthdcn, aplyurladdr,
          sbmsndcmntcn, etcmttrcn, refurladdr1, refurladdr2,
          sprtsclcnt, sprtarvlseqyn,
          sprttrgtminage, sprttrgtmaxage, sprttrgtagelmtyn,
          mrgsttscd, earncndsecd, earnminamt, earnmaxamt, earnetccn,
          addaplyqlfccndcn, ptcpprptrgtcn, inqcnt,
          rgtrinstcd, rgtrinstcdnm, rgtrupinstcd, rgtrupinstcdnm,
          rgtrhghrkinstcd, rgtrhghrkinstcdnm,
          zipcd, plcymajorcd, jobcd, schoolcd,
          aplyymd, frstregdt, lastmdfcndt, sbizcd,
          raw_data
        ) VALUES (
          $1, $2, $3, $4, $5, $6, $7, $8, $9, $10,
          $11, $12, $13, $14, $15, $16, $17, $18, $19, $20,
          $21, $22, $23, $24, $25, $26, $27, $28, $29, $30,
          $31, $32, $33, $34, $35, $36, $37, $38, $39, $40,
          $41, $42, $43, $44, $45, $46, $47, $48, $49, $50,
          $51, $52, $53, $54, $55, $56, $57, $58, $59, $60,
          $61, $62, $63, $64, $65, $66, $67, $68, $69, $70,
          $71, $72, $73, $74, $75
        )
        ON CONFLICT (id) DO UPDATE SET
          title = EXCLUDED.title,
          category = EXCLUDED.category,
          description = EXCLUDED.description,
          content = EXCLUDED.content,
          deadline = EXCLUDED.deadline,
          start_date = EXCLUDED.start_date,
          end_date = EXCLUDED.end_date,
          application_url = EXCLUDED.application_url,
          requirements = EXCLUDED.requirements,
          region = EXCLUDED.region,
          target_age = EXCLUDED.target_age,
          tags = EXCLUDED.tags,
          cached_at = EXCLUDED.cached_at,
          plcyno = EXCLUDED.plcyno,
          plcynm = EXCLUDED.plcynm,
          plcyexplncn = EXCLUDED.plcyexplncn,
          plcykywdnm = EXCLUDED.plcykywdnm,
          lclsfnm = EXCLUDED.lclsfnm,
          mclsfnm = EXCLUDED.mclsfnm,
          plcysprtcn = EXCLUDED.plcysprtcn,
          bscplancycl = EXCLUDED.bscplancycl,
          bscplanplcywayno = EXCLUDED.bscplanplcywayno,
          bscplanfcsasmtno = EXCLUDED.bscplanfcsasmtno,
          bscplanasmtno = EXCLUDED.bscplanasmtno,
          pvsninstgroupcd = EXCLUDED.pvsninstgroupcd,
          plcypvsnmthdcd = EXCLUDED.plcypvsnmthdcd,
          plcyaprvsttscd = EXCLUDED.plcyaprvsttscd,
          sprvsninstcd = EXCLUDED.sprvsninstcd,
          sprvsninstcdnm = EXCLUDED.sprvsninstcdnm,
          sprvsninstpicnm = EXCLUDED.sprvsninstpicnm,
          operinstcd = EXCLUDED.operinstcd,
          operinstcdnm = EXCLUDED.operinstcdnm,
          operinstpicnm = EXCLUDED.operinstpicnm,
          sprtscllmtyn = EXCLUDED.sprtscllmtyn,
          aplyprdsecd = EXCLUDED.aplyprdsecd,
          bizprdsecd = EXCLUDED.bizprdsecd,
          bizprdbgngymd = EXCLUDED.bizprdbgngymd,
          bizprdendymd = EXCLUDED.bizprdendymd,
          bizprdetccn = EXCLUDED.bizprdetccn,
          plcyaplymthdcn = EXCLUDED.plcyaplymthdcn,
          srngmthdcn = EXCLUDED.srngmthdcn,
          aplyurladdr = EXCLUDED.aplyurladdr,
          sbmsndcmntcn = EXCLUDED.sbmsndcmntcn,
          etcmttrcn = EXCLUDED.etcmttrcn,
          refurladdr1 = EXCLUDED.refurladdr1,
          refurladdr2 = EXCLUDED.refurladdr2,
          sprtsclcnt = EXCLUDED.sprtsclcnt,
          sprtarvlseqyn = EXCLUDED.sprtarvlseqyn,
          sprttrgtminage = EXCLUDED.sprttrgtminage,
          sprttrgtmaxage = EXCLUDED.sprttrgtmaxage,
          sprttrgtagelmtyn = EXCLUDED.sprttrgtagelmtyn,
          mrgsttscd = EXCLUDED.mrgsttscd,
          earncndsecd = EXCLUDED.earncndsecd,
          earnminamt = EXCLUDED.earnminamt,
          earnmaxamt = EXCLUDED.earnmaxamt,
          earnetccn = EXCLUDED.earnetccn,
          addaplyqlfccndcn = EXCLUDED.addaplyqlfccndcn,
          ptcpprptrgtcn = EXCLUDED.ptcpprptrgtcn,
          inqcnt = EXCLUDED.inqcnt,
          rgtrinstcd = EXCLUDED.rgtrinstcd,
          rgtrinstcdnm = EXCLUDED.rgtrinstcdnm,
          rgtrupinstcd = EXCLUDED.rgtrupinstcd,
          rgtrupinstcdnm = EXCLUDED.rgtrupinstcdnm,
          rgtrhghrkinstcd = EXCLUDED.rgtrhghrkinstcd,
          rgtrhghrkinstcdnm = EXCLUDED.rgtrhghrkinstcdnm,
          zipcd = EXCLUDED.zipcd,
          plcymajorcd = EXCLUDED.plcymajorcd,
          jobcd = EXCLUDED.jobcd,
          schoolcd = EXCLUDED.schoolcd,
          aplyymd = EXCLUDED.aplyymd,
          frstregdt = EXCLUDED.frstregdt,
          lastmdfcndt = EXCLUDED.lastmdfcndt,
          sbizcd = EXCLUDED.sbizcd,
          raw_data = EXCLUDED.raw_data,
          updated_at = CURRENT_TIMESTAMP
      `;

      const values = [
        // Basic backward-compatible fields
        policy.id,
        policy.title,
        policy.category,
        policy.description,
        policy.content,
        policy.deadline,
        policy.start_date,
        policy.end_date,
        policy.application_url,
        JSON.stringify(policy.requirements || []),
        JSON.stringify(policy.region || []),
        JSON.stringify(policy.target_age || {}),
        JSON.stringify(policy.tags || []),
        policy.cached_at,

        // 2025 API 전체 60개 필드
        policy.plcyNo,
        policy.plcyNm,
        policy.plcyExplnCn,
        policy.plcyKywdNm,
        policy.lclsfNm,
        policy.mclsfNm,
        policy.plcySprtCn,
        policy.bscPlanCycl,
        policy.bscPlanPlcyWayNo,
        policy.bscPlanFcsAsmtNo,
        policy.bscPlanAsmtNo,
        policy.pvsnInstGroupCd,
        policy.plcyPvsnMthdCd,
        policy.plcyAprvSttsCd,
        policy.sprvsnInstCd,
        policy.sprvsnInstCdNm,
        policy.sprvsnInstPicNm,
        policy.operInstCd,
        policy.operInstCdNm,
        policy.operInstPicNm,
        policy.sprtSclLmtYn,
        policy.aplyPrdSeCd,
        policy.bizPrdSeCd,
        policy.bizPrdBgngYmd,
        policy.bizPrdEndYmd,
        policy.bizPrdEtcCn,
        policy.plcyAplyMthdCn,
        policy.srngMthdCn,
        policy.aplyUrlAddr,
        policy.sbmsnDcmntCn,
        policy.etcMttrCn,
        policy.refUrlAddr1,
        policy.refUrlAddr2,
        policy.sprtSclCnt,
        policy.sprtArvlSeqYn,
        policy.sprtTrgtMinAge,
        policy.sprtTrgtMaxAge,
        policy.sprtTrgtAgeLmtYn,
        policy.mrgSttsCd,
        policy.earnCndSeCd,
        policy.earnMinAmt,
        policy.earnMaxAmt,
        policy.earnEtcCn,
        policy.addAplyQlfcCndCn,
        policy.ptcpPrpTrgtCn,
        policy.inqCnt,
        policy.rgtrInstCd,
        policy.rgtrInstCdNm,
        policy.rgtrUpInstCd,
        policy.rgtrUpInstCdNm,
        policy.rgtrHghrkInstCd,
        policy.rgtrHghrkInstCdNm,
        policy.zipCd,
        policy.plcyMajorCd,
        policy.jobCd,
        policy.schoolCd,
        policy.aplyYmd,
        policy.frstRegDt,
        policy.lastMdfcnDt,
        policy.sbizCd,
        JSON.stringify(policy.raw_data || {})
      ];

      await db.query(query, values);
    }
  }

  /**
   * 캐시된 정책 데이터 조회
   */
  async getCachedPolicies(params = {}) {
    try {
      const {
        page = 1,
        limit = 20,
        category,
        region,
        searchText
      } = params;

      let whereConditions = ["status = 'active'"];
      let queryParams = [];
      let paramIndex = 1;

      // 2025년 이후 정책만 필터링
      whereConditions.push(`EXTRACT(YEAR FROM COALESCE(start_date, updated_at)) >= $${paramIndex}`);
      queryParams.push(2025);
      paramIndex++;

      if (category) {
        whereConditions.push(`category = $${paramIndex}`);
        queryParams.push(category);
        paramIndex++;
      }

      if (region) {
        whereConditions.push(`region @> $${paramIndex}`);
        queryParams.push(JSON.stringify([region]));
        paramIndex++;
      }

      if (searchText) {
        whereConditions.push(`(title ILIKE $${paramIndex} OR description ILIKE $${paramIndex})`);
        queryParams.push(`%${searchText}%`);
        paramIndex++;
      }

      const offset = (page - 1) * limit;

      const query = `
        SELECT * FROM policies
        WHERE ${whereConditions.join(' AND ')}
        ORDER BY popularity_score DESC, created_at DESC
        LIMIT $${paramIndex} OFFSET $${paramIndex + 1}
      `;

      queryParams.push(limit, offset);

      const result = await db.query(query, queryParams);

      // 전체 개수 조회
      const countQuery = `
        SELECT COUNT(*) FROM policies
        WHERE ${whereConditions.join(' AND ')}
      `;

      const countResult = await db.query(countQuery, queryParams.slice(0, -2));
      const total = parseInt(countResult.rows[0].count);

      return {
        policies: result.rows,
        pagination: {
          page,
          limit,
          total,
          hasNext: offset + limit < total
        }
      };

    } catch (error) {
      console.error('캐시된 정책 조회 실패:', error);
      return {
        policies: [],
        pagination: { page: 1, limit, total: 0, hasNext: false }
      };
    }
  }

  // 유틸리티 메서드들
  mapCategoryToCode(category) {
    const mapping = {
      '장학금': '023010',
      '창업지원': '023020',
      '취업지원': '023030',
      '주거지원': '023040',
      '생활복지': '023050',
      '문화': '023060',
      '참여권리': '023070'
    };
    return mapping[category] || '';
  }

  mapCodeToCategory(code) {
    const mapping = {
      '023010': '장학금',
      '023020': '창업지원',
      '023030': '취업지원',
      '023040': '주거지원',
      '023050': '생활복지',
      '023060': '문화',
      '023070': '참여권리'
    };
    return mapping[code] || '기타';
  }

  parseDate(dateString, type = 'end') {
    if (!dateString) return null;

    try {
      // "2024.01.01~2024.12.31" 형태 파싱
      const dates = dateString.match(/(\d{4}\.?\d{2}\.?\d{2})/g);
      if (!dates) return null;

      const dateIndex = type === 'start' ? 0 : dates.length - 1;
      const date = dates[dateIndex].replace(/\./g, '-');

      return new Date(date).toISOString().split('T')[0];
    } catch (error) {
      return null;
    }
  }

  parseAge(ageInfo) {
    if (!ageInfo) return null;

    try {
      const ageMatch = ageInfo.match(/(\d+).*?(\d+)/);
      if (ageMatch) {
        return {
          min: parseInt(ageMatch[1]),
          max: parseInt(ageMatch[2])
        };
      }

      const singleAge = ageInfo.match(/(\d+)/);
      if (singleAge) {
        const age = parseInt(singleAge[1]);
        return { min: age, max: age };
      }

      return null;
    } catch (error) {
      return null;
    }
  }

  parseRegion(regionCode) {
    // 지역 코드를 지역명으로 변환
    const regionMapping = {
      '003002001': '서울',
      '003002002': '부산',
      '003002003': '대구',
      // ... 더 많은 지역 코드 매핑
      '003002000': '전국'
    };

    return regionMapping[regionCode] ? [regionMapping[regionCode]] : ['전국'];
  }

  parseRequirements(ageInfo) {
    if (!ageInfo) return [];
    return [ageInfo];
  }

  parseTags(keyword) {
    if (!keyword) return [];
    return keyword.split(',').map(tag => tag.trim()).filter(Boolean);
  }

  parseBenefits(content) {
    if (!content) return [];
    // 지원내용 파싱 로직
    return [content];
  }

  parseDocuments(documents) {
    if (!documents) return [];
    return documents.split(',').map(doc => doc.trim()).filter(Boolean);
  }

  delay(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}

module.exports = new OntongService();