# Hermes Agent + Daytona SDK on Render

এই repository Render-এ Hermes Agent-কে **always-on Background Worker** হিসেবে চালানোর জন্য তৈরি। Official Hermes Docker image ব্যবহার করা হয়েছে, আর Daytona Python SDK আলাদা virtual environment-এ ইনস্টল করা হয়েছে।

## Repository-তে কী আছে

- `Dockerfile` — Official Hermes image-এর উপর Daytona SDK যোগ করে।
- `render.yaml` — Render Background Worker, Singapore region এবং persistent disk তৈরি করে।
- `.env.example` — provider ও integration secret-এর উদাহরণ।
- `scripts/check_daytona.py` — Daytona SDK import smoke test।

## Deploy করার নিয়ম

1. এই folder-এর সব file একটি নতুন GitHub repository-তে upload/push করুন।
2. Render Dashboard খুলে **New → Blueprint** নির্বাচন করুন।
3. GitHub repository connect করে `render.yaml` detect হলে **Apply** করুন।
4. Service তৈরি হলে Render-এর **Environment** tab-এ প্রয়োজনীয় secret যোগ করুন। উদাহরণ:
   - `OPENROUTER_API_KEY` — OpenRouter ব্যবহার করলে।
   - `DAYTONA_API_KEY` — Daytona Sandbox ব্যবহার করলে।
   - আপনার messaging platform-এর bot token, যেমন `TELEGRAM_BOT_TOKEN`।
5. Deploy complete হলে Render service-এর **Shell** খুলে initial setup চালান:

   ```bash
   hermes setup
   ```

   Nous Portal ব্যবহার করলে বিকল্পভাবে:

   ```bash
   hermes setup --portal
   ```

6. Messaging platform connect/configure করতে চালান:

   ```bash
   hermes gateway setup
   ```

7. Shell থেকে বের হয়ে service restart করুন। Render-এর **Logs** tab-এ gateway startup/logs দেখুন।

> Setup wizard-এ model provider, model এবং আপনার প্রয়োজনীয় messaging platform configure করতে হবে। Environment variable-এ শুধু API key যোগ করলেই সব platform স্বয়ংক্রিয়ভাবে configure হয়ে যায় না।

## Daytona SDK ব্যবহার

Daytona SDK-টি Hermes-এর sealed Python environment পরিবর্তন না করে `/opt/daytona-venv`-এ রাখা হয়েছে। Python script-এ Daytona SDK ব্যবহার করতে `daytona-python` কমান্ড দিন:

```bash
daytona-python scripts/check_daytona.py
```

Daytona Sandbox তৈরি করতে হলে Render Environment-এ `DAYTONA_API_KEY` সেট করতে হবে।

## গুরুত্বপূর্ণ Render বিষয়

- এই repository **Background Worker** ব্যবহার করে। এটি Telegram/Discord/অন্যান্য outbound-connected gateway-এর জন্য উপযুক্ত; এটি নিজে থেকে public HTTP endpoint দেয় না।
- `/opt/data`-তে 1 GB persistent disk attach করা আছে। Hermes-এর config, credentials, sessions এবং memory এই path-এ থাকবে।
- Persistent disk ব্যবহার করতে Render-এর paid service plan প্রয়োজন। এই Blueprint `1c-2g` worker plan নির্বাচন করে; Render-এর compute plan অনুযায়ী খরচ হবে।
- `render.yaml`-এ Singapore region রাখা হয়েছে, বাংলাদেশ থেকে latency কম রাখার উদ্দেশ্যে। Render account/region availability অনুযায়ী dashboard-এ region পরিবর্তন করা যায়।
- API keys বা bot tokens কখনো GitHub repository-তে commit করবেন না। Render Dashboard-এর Environment section-এ secret হিসেবে রাখুন।
- `latest` tag upstream Hermes-এর নতুন image নিতে পারে; production-এ নির্দিষ্ট version pin করতে চাইলে Dockerfile-এর `FROM` tag-টি release version দিয়ে বদলান।

## Local Docker test

```bash
docker build -t hermes-render .
docker run --rm -it \
  -v hermes-data:/opt/data \
  -e OPENROUTER_API_KEY=your_key \
  hermes-render setup
```

Setup শেষ হলে gateway চালাতে:

```bash
docker run -d --name hermes-agent \
  -v hermes-data:/opt/data \
  -e OPENROUTER_API_KEY=your_key \
  -e DAYTONA_API_KEY=your_daytona_key \
  hermes-render gateway run
```

## Official documentation

- Hermes installation: https://hermes-agent.nousresearch.com/docs/getting-started/installation
- Hermes Docker: https://hermes-agent.nousresearch.com/docs/user-guide/docker
- Daytona Python SDK: https://www.daytona.com/docs/python-sdk
- Render Blueprints: https://render.com/docs/blueprint-spec
- Render persistent disks: https://render.com/docs/disks
