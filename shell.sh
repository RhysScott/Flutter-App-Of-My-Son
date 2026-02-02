#!/bin/bash

curl -i -k -X POST 'https://spark-api-open.xf-yun.com/v1/chat/completions' \
--header 'Authorization: Bearer xWLVAMGePfIRFvIaeBoA:PnIxuCwYawuOXjpdiVgp' \
--header 'Content-Type: application/json' \
--data '{
    "model":"generalv3.5",
    "messages": [
        {
            "role": "user",
            "content": "来一个只有程序员能听懂的笑话"
        }
    ],
    "stream": true
}'
