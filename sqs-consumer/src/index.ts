import AWS from 'aws-sdk';
import dotenv from 'dotenv';
dotenv.config();

const sqs = new AWS.SQS({
  region: process.env.AWS_REGION,
  endpoint: process.env.AWS_ENDPOINT
});

async function pollMessages(): Promise<void> {
  const params: AWS.SQS.ReceiveMessageRequest = {
    QueueUrl: process.env.SQS_URL!,
    MaxNumberOfMessages: 5,
    WaitTimeSeconds: 10
  };

  while (true) {
    const data = await sqs.receiveMessage(params).promise();

    if (data.Messages && data.Messages.length > 0) {
      for (const msg of data.Messages) {
        console.log('📨 Mensagem recebida da fila:', msg.Body);

        await sqs.deleteMessage({
          QueueUrl: process.env.SQS_URL!,
          ReceiptHandle: msg.ReceiptHandle!
        }).promise();
      }
    }
  }
}

pollMessages();
