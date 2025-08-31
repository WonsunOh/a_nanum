# PowerShell 스크립트: deploy-onetime.ps1
# 경고: 이 파일에는 비밀번호가 포함되어 있으므로 사용 후 즉시 삭제하세요.

# 1. DB 비밀번호를 변수에 직접 할당합니다.
$dbPassword = "ows8551002!@"

# 2. 비밀번호를 환경 변수로 설정합니다.
$env:SUPABASE_DB_PASSWORD = $dbPassword

# 3. 확인 질문 없이(--quiet) db push를 실행합니다.
Write-Host "Supabase DB에 변경사항을 Push합니다..."
supabase db push --quiet

# 4. 스크립트 종료 후 비밀번호가 담긴 환경 변수를 삭제합니다.
Remove-Item Env:\SUPABASE_DB_PASSWORD

Write-Host "Push가 완료되었습니다."