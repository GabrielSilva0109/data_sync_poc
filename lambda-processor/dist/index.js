"use strict";

Object.defineProperty(exports, "__esModule", { value: true });
exports.handler = void 0;
const client_sqs_1 = require("@aws-sdk/client-sqs");
const sqs = new client_sqs_1.SQSClient({
    region: process.env.AWS_REGION || "us-east-1"
});
const handler = async (event) => {
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
    await sqs.send(new client_sqs_1.SendMessageCommand(params));
    console.log("Mensagem enviada para SQS:", message);
    return { statusCode: 200, body: JSON.stringify({ success: true }) };
};
exports.handler = handler;
