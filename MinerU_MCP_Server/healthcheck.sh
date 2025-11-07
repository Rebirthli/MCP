#!/bin/bash
# MinerU MCP Server 健康检查脚本
# 用途：监控服务健康状态，异常时自动重启

HEALTH_URL="http://localhost:8000/health"
LOG_FILE="/var/log/mineru-mcp/healthcheck.log"
MAX_FAILURES=3
FAILURE_COUNT=0

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

check_health() {
    RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "$HEALTH_URL")

    if [ "$RESPONSE" = "200" ]; then
        log_message "✓ Health check passed (HTTP $RESPONSE)"
        return 0
    else
        log_message "✗ Health check failed (HTTP $RESPONSE)"
        return 1
    fi
}

restart_service() {
    log_message "⚠ Attempting to restart MinerU MCP Server..."

    # 根据部署方式选择重启命令
    if systemctl is-active --quiet mineru-mcp; then
        sudo systemctl restart mineru-mcp
        log_message "✓ Service restarted via systemd"
    elif docker ps | grep -q mineru-mcp-server; then
        docker-compose -f /opt/mineru-mcp-server/docker-compose.yml restart
        log_message "✓ Service restarted via docker-compose"
    else
        log_message "✗ Could not determine how to restart service"
        return 1
    fi

    # 等待服务启动
    sleep 10

    # 验证重启成功
    if check_health; then
        log_message "✓ Service restart successful"
        FAILURE_COUNT=0
        return 0
    else
        log_message "✗ Service restart failed"
        return 1
    fi
}

send_alert() {
    local message="$1"

    # 发送邮件告警（需要配置 mail 命令）
    # echo "$message" | mail -s "MinerU MCP Alert" admin@example.com

    # 发送钉钉告警（需要配置 webhook）
    # curl -X POST https://oapi.dingtalk.com/robot/send?access_token=YOUR_TOKEN \
    #   -H 'Content-Type: application/json' \
    #   -d "{\"msgtype\":\"text\",\"text\":{\"content\":\"$message\"}}"

    # 发送 Slack 告警（需要配置 webhook）
    # curl -X POST YOUR_SLACK_WEBHOOK_URL \
    #   -H 'Content-Type: application/json' \
    #   -d "{\"text\":\"$message\"}"

    log_message "Alert sent: $message"
}

# 主逻辑
if ! check_health; then
    FAILURE_COUNT=$((FAILURE_COUNT + 1))
    log_message "Failure count: $FAILURE_COUNT/$MAX_FAILURES"

    if [ $FAILURE_COUNT -ge $MAX_FAILURES ]; then
        log_message "⚠ Maximum failures reached, attempting restart..."

        if restart_service; then
            send_alert "MinerU MCP Server was down and has been restarted successfully."
        else
            send_alert "CRITICAL: MinerU MCP Server is down and restart failed! Manual intervention required."
        fi
    fi
else
    # 健康检查通过，重置失败计数
    if [ $FAILURE_COUNT -gt 0 ]; then
        log_message "Service recovered after $FAILURE_COUNT failures"
        FAILURE_COUNT=0
    fi
fi

exit 0
