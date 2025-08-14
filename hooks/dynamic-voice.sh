#!/bin/bash

# Dynamic Voice Notification Hook - Extracts agent type and creates contextual messages

LOG_FILE="/home/harshank/repos/payroll/.claude/hooks/voice-notifications.log"

# Log hook trigger
echo "[$(date '+%Y-%m-%d %H:%M:%S')] 🎵 Dynamic voice hook triggered" >> "$LOG_FILE"

# Read JSON input from stdin to extract agent information
json_input=""
while IFS= read -r line || [ -n "$line" ]; do
    json_input+="$line"
done

# Extract agent type and tool information
if command -v jq &> /dev/null; then
    # Use jq for proper JSON parsing
    tool_name=$(echo "$json_input" | jq -r '.tool_name // "unknown"')
    subagent_type=$(echo "$json_input" | jq -r '.tool_input.subagent_type // "general-purpose"')
    tool_response=$(echo "$json_input" | jq -r '.tool_response // ""' | head -c 200)
else
    # Fallback to grep parsing
    tool_name=$(echo "$json_input" | grep -o '"tool_name":"[^"]*"' | cut -d'"' -f4)
    subagent_type=$(echo "$json_input" | grep -o '"subagent_type":"[^"]*"' | cut -d'"' -f4)
    tool_response=$(echo "$json_input" | head -c 200)
fi

# Default values if extraction fails
tool_name=${tool_name:-"unknown"}
subagent_type=${subagent_type:-"general-purpose"}

# Create dynamic message based on agent type
case "$subagent_type" in
    "backend-developer"|"mern-stack-expert")
        message="Backend development completed successfully"
        ;;
    "frontend-developer"|"react-specialist")
        message="Frontend development completed successfully"
        ;;
    "payroll-specialist")
        message="Payroll calculation task completed successfully"
        ;;
    "attendance-specialist")
        message="Attendance processing completed successfully"
        ;;
    "shift-scheduler")
        message="Shift scheduling task completed successfully"
        ;;
    "leave-management-expert")
        message="Leave management update completed successfully"
        ;;
    "compliance-reporting-specialist")
        message="Compliance report generated successfully"
        ;;
    "device-integration-expert")
        message="Device integration completed successfully"
        ;;
    *)
        message="Agent task completed successfully"
        ;;
esac

# Log the extracted information
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Tool: $tool_name, Agent: $subagent_type" >> "$LOG_FILE"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Message: $message" >> "$LOG_FILE"

# Generate voice only for Task tool (agent completions)
if [ "$tool_name" = "Task" ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 🎵 Generating voice for $subagent_type agent" >> "$LOG_FILE"
    
    # Use the working ElevenLabs method with dynamic message
    python3 -c "
import requests
import subprocess
from datetime import datetime

try:
    # ElevenLabs API call with dynamic message
    api_key = '$ELEVAN_LABS_API_KEY'
    voice_id = '21m00Tcm4TlvDq8ikWAM'  # Rachel
    url = f'https://api.elevenlabs.io/v1/text-to-speech/{voice_id}'
    
    headers = {
        'Accept': 'audio/mpeg',
        'Content-Type': 'application/json',
        'xi-api-key': api_key
    }
    
    data = {
        'text': '$message',
        'model_id': 'eleven_turbo_v2',
        'voice_settings': {
            'stability': 0.5,
            'similarity_boost': 0.75
        }
    }
    
    response = requests.post(url, json=data, headers=headers, timeout=30)
    
    if response.status_code == 200:
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        output_file = f'/home/harshank/Desktop/voice_{timestamp}.mp3'
        
        with open(output_file, 'wb') as f:
            f.write(response.content)
        
        # Play with VLC
        subprocess.run(['vlc', '--intf', 'dummy', '--play-and-exit', output_file], 
                      stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=10)
        
        print('Voice generated and played successfully')
    else:
        print(f'API Error: {response.status_code}')

except Exception as e:
    print(f'Error: {e}')
" >> "$LOG_FILE" 2>&1

fi

echo "[$(date '+%Y-%m-%d %H:%M:%S')] ✅ Dynamic voice hook completed" >> "$LOG_FILE"