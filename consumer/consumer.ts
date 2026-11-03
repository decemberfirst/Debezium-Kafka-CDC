import { Kafka } from 'kafkajs';

const kafka = new Kafka({
  clientId: 'orders-service',
  brokers: ['localhost:9094'],
});

const consumer = kafka.consumer({
  groupId: 'orders-consumer-group-cdc',
});

async function start() {
  await consumer.connect();

  await consumer.subscribe({
    topic: 'myapp.public.orders',
    fromBeginning: true,
  });

  await consumer.run({
    eachMessage: async ({ message }) => {
      if (!message.value) return;

      const event = JSON.parse(message.value.toString());

      // CHECK LSN, ROW_ID, OP COMBINED FOR IDEMPOTENCY
      console.log(event);
    },
  });
}

start().catch(console.error);

process.on('SIGINT', async () => {
  await consumer.disconnect();
  process.exit(0);
});
