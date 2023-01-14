'use strict';

const functions = require('@google-cloud/functions-framework');
const {PubSub} = require('@google-cloud/pubsub');

const pubSubClient = new PubSub();

functions.cloudEvent('PingPongPubSub', cloudEvent => {
  const base64name = cloudEvent.data.message.data;

  const received = base64name
    ? Buffer.from(base64name, 'base64').toString()
    : 'unknown';


  console.log(`Receive: ${received}`);
  const send = received == 'ping' ? 'pong' : 'ping'
  publishMessage(send);
});

async function publishMessage(name) {
  const dataBuffer = Buffer.from(name);

  try {
    const messageId = await pubSubClient
      .topic(env.TOPIC_ID)
      .publishMessage({data: dataBuffer});
    console.log(`Message ${messageId} published.`);
  } catch (error) {
    console.error(`Received error while publishing: ${error.message}`);
    process.exitCode = 1;
  }
}