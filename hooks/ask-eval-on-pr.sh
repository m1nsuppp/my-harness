#!/bin/bash
# PreToolUse 훅: gh pr create 직전 사용자에게 /eval(머스크) 검토 의사 확인
# - 첫 호출에서만 발동, 세션당 1회 (sentinel: /tmp/claude-eval-asked-$session_id)
# - 모델에게 AskUserQuestion 으로 객관식 다이얼로그를 띄우라고 지시 (deny + reason)

INPUT=$(cat)
SID=$(echo "$INPUT" | jq -r .session_id)
SENTINEL="/tmp/claude-eval-asked-$SID"

[ -f "$SENTINEL" ] && exit 0
touch "$SENTINEL"

REASON='PR 생성 직전입니다. AskUserQuestion 툴을 사용해 사용자에게 "eval 스킬로 머스크에게 결과물 검토를 받으시겠습니까?"를 묻고, 선택지는 ["예, /eval 로 검토 받기", "아니오, 그대로 PR 생성"]으로 제시하세요. 응답에 따라 /eval 을 먼저 실행하거나 곧바로 gh pr create 를 재시도하세요.'

jq -nc --arg reason "$REASON" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "deny",
    permissionDecisionReason: $reason
  }
}'
