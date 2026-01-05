#!/usr/bin/env python3
import requests
import json
import time

BASE_URL = 'http://localhost:3000/api'
LOGIN_ENDPOINT = f'{BASE_URL}/auth/login'
STANDARDS_ENDPOINT = f'{BASE_URL}/health-profile/standards'
PROFILE_ENDPOINT = f'{BASE_URL}/health-profile'
DOCTOR_NOTES_ENDPOINT = f'{BASE_URL}/health-profile/doctor-notes'
ANALYSIS_ENDPOINT = f'{BASE_URL}/health-profile/analysis/personalized'

# 登录凭证
login_payload = {
    'identifier': 'test@example.com',
    'password': 'Password123!'
}

print("=" * 60)
print("测试个性化健康档案API")
print("=" * 60)

try:
    # 1. 登录获取token
    print("\n1. 登录获取Token...")
    response = requests.post(LOGIN_ENDPOINT, json=login_payload, timeout=5)
    print(f"   状态码: {response.status_code}")
    login_data = response.json()
    print(f"   响应: {json.dumps(login_data, indent=2, ensure_ascii=False)}")
    
    if not login_data.get('success') or not login_data.get('data', {}).get('accessToken'):
        print("   ❌ 登录失败")
        exit(1)
    
    token = login_data['data']['accessToken']
    print(f"   ✅ Token获取成功")
    
    headers = {'Authorization': f'Bearer {token}'}
    
    # 2. 获取健康档案
    print("\n2. 获取健康档案 (GET /health-profile)...")
    response = requests.get(PROFILE_ENDPOINT, headers=headers, timeout=5)
    print(f"   状态码: {response.status_code}")
    profile_data = response.json()
    print(f"   响应: {json.dumps(profile_data, indent=2, ensure_ascii=False)[:200]}...")
    
    # 3. 获取个性化标准 (主要测试)
    print("\n3. 获取个性化标准 (GET /health-profile/standards)...")
    response = requests.get(STANDARDS_ENDPOINT, headers=headers, timeout=5)
    print(f"   状态码: {response.status_code}")
    standards_data = response.json()
    if response.status_code == 200:
        print(f"   ✅ 成功! 返回数据预览:")
        print(f"   {json.dumps(standards_data, indent=2, ensure_ascii=False)[:300]}...")
    else:
        print(f"   ❌ 失败! 错误信息: {standards_data.get('error')}")
    
    # 4. 更新医生建议
    print("\n4. 更新医生建议 (PUT /health-profile/doctor-notes)...")
    doctor_notes_payload = {
        'doctorNotes': '患者健康状况良好，建议继续保持现有运动频率'
    }
    response = requests.put(DOCTOR_NOTES_ENDPOINT, json=doctor_notes_payload, headers=headers, timeout=5)
    print(f"   状态码: {response.status_code}")
    doctor_data = response.json()
    print(f"   响应: {json.dumps(doctor_data, indent=2, ensure_ascii=False)}")
    
    # 5. 获取个性化分析
    print("\n5. 获取个性化分析 (GET /health-profile/analysis/personalized)...")
    response = requests.get(ANALYSIS_ENDPOINT, headers=headers, timeout=5)
    print(f"   状态码: {response.status_code}")
    analysis_data = response.json()
    if response.status_code == 200:
        print(f"   ✅ 成功! 返回数据预览:")
        print(f"   {json.dumps(analysis_data, indent=2, ensure_ascii=False)[:300]}...")
    else:
        print(f"   ❌ 失败! 错误信息: {analysis_data.get('error')}")
    
    print("\n" + "=" * 60)
    print("测试完成!")
    print("=" * 60)
    
except requests.exceptions.ConnectionError as e:
    print(f"❌ 连接错误: 无法连接到 {BASE_URL}")
    print(f"   请确保后端服务在 http://localhost:3000 运行")
except requests.exceptions.Timeout:
    print(f"❌ 请求超时")
except Exception as e:
    print(f"❌ 错误: {e}")
