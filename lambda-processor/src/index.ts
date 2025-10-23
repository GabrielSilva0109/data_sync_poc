import { SQSClient, SendMessageCommand } from "@aws-sdk/client-sqs";

const sqs = new SQSClient({
  region: process.env.AWS_REGION || "us-east-1"
});

export const handler = async (event: any) => {
  console.log("Evento recebido do EventBridge:", JSON.stringify(event, null, 2));

  const queueUrl = process.env.SQS_URL;
  if (!queueUrl) {
    throw new Error("Variável de ambiente SQS_URL não configurada");
  }

  const message = {
    type: event["detail-type"],
    data: event.detail
  };

  const params = {
    QueueUrl: queueUrl,
    MessageBody: JSON.stringify(message)
  };

  await sqs.send(new SendMessageCommand(params));

  console.log("Mensagem enviada para SQS:", message);
  return { statusCode: 200, body: JSON.stringify({ success: true }) };
};
