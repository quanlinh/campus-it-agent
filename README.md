# Campus IT Agent

A backend AI agent portfolio starter for Quan Tran's UW application.
It retrieves fictional campus IT documents, reads fictional service status,
and prepares ticket drafts. This is an independent demonstration, not a UW
service, and its sample policies are not UW policies.

## Run the first demo

Requires Python 3.12+ with SQLite FTS5 enabled. No pip dependencies.
Open a terminal in this extracted project folder:

```bash
python -m agent "My VPN connection fails. What should I try?" --service vpn --draft
python -m unittest discover -s tests -v
python -m evals.run
```

Use `python3` instead of `python` if required on your system.
The first command runs a **scripted offline workflow**, not an LLM. It returns
retrieved documents, a service-status fixture, a ticket draft, and a tool trace
as JSON. Drafts remain in memory/output only; nothing is submitted or saved
to a ticket system. This mode makes plumbing easy to inspect before paying
for model calls.

## Enable the actual LLM agent

Set your own API key and a Responses-compatible model available to your
account. Never put credentials in source files or commit them.

PowerShell (Windows):

```powershell
$env:OPENAI_API_KEY = Read-Host "Enter your API key" -MaskInput
$env:OPENAI_MODEL = Read-Host "Enter your model ID"
python -m agent "My VPN fails. Check its status, suggest documented steps, and draft a ticket." --live
```

`-MaskInput` requires PowerShell 7.1+. In an older shell, configure the key
through your operating system environment settings instead.

Bash:

```bash
read -rs -p 'API key: ' OPENAI_API_KEY
export OPENAI_API_KEY
read -r -p 'Model ID: ' OPENAI_MODEL
export OPENAI_MODEL
python -m agent "My VPN fails. Check its status, suggest documented steps, and draft a ticket." --live
```

In live mode the model chooses tools, receives results, and continues until
it answers or reaches six turns. A key does not grant all model access;
choose a model your account supports. Live runs send your question and
retrieved sample documents to the provider and may incur API charges.
No live model request was made during initial project validation.

## Architecture and engineering choices

1. The CLI accepts a question.
2. The Responses API receives the instructions and three strict tool schemas.
3. Model-requested tools pass through application-level validation.
4. `search_knowledge` retrieves up to three Markdown documents using SQLite
   FTS5/BM25. Each tiny sample document is one chunk.
5. `get_service_status` reads a timestamped local fixture.
6. `draft_ticket` returns a structured draft with `submitted: false`.
7. Tool results are returned to the model. Final document citation IDs are
   checked against documents actually retrieved during that run.

The orchestrator is deliberately small: it exposes the control loop and
tool boundaries without hiding them inside an agent framework. Python is
used for this AI portfolio project; Quan's professional backend experience
is C# / ASP.NET Core and Azure Service Fabric.

Provider protocol reference:
https://developers.openai.com/api/docs/guides/function-calling

## What this first version demonstrates

- Retrieval-augmented generation in live mode, using lexical retrieval.
- LLM function calling with a controlled tool allowlist and validated inputs.
- Bounded execution, provider timeouts, error handling, and a tool trace.
- Citation ID validation and a tool that can only produce drafts.
- Unit tests with injected providers and a small retrieval evaluation.
- A Dockerfile for reproducible execution.

```bash
docker build -t campus-it-agent .
docker run --rm campus-it-agent "VPN fails" --service vpn --draft
docker run --rm -e OPENAI_API_KEY -e OPENAI_MODEL campus-it-agent "Check VPN status" --live
```

Docker execution was not validated in the initial environment.

## Honest limits and next milestones

This is a starter, not yet a finished application exhibit. Lexical retrieval
is not embedding/vector search. Four documents and five evaluation queries
are only smoke coverage. Citation checks confirm source IDs, not whether
each statement is actually supported. Instructions to resist prompt
injection and avoid credential collection are prompt-level mitigations,
not proven guarantees. There is no authentication, persistence, multi-turn
chat, real status integration, ticket submission, MCP, CrewAI, or web UI.
Tool traces can contain user text: use fictional inputs for demos.

Next milestones:

1. Run a live model locally and inspect retrieval → tool → answer traces.
2. Add embeddings and compare lexical, semantic, and hybrid retrieval on a
   larger evaluation set, including unsupported questions.
3. Evaluate live answer correctness, citation support, tool choice, and
   prompt-injection behavior with benign adversarial documents.
4. Add a small demo interface, real read-only public status integration,
   and an MCP adapter if relevant to the role.
5. Record a three-minute demo and document measured results and tradeoffs.

Describe this on your resume only after you have run it, understand the
design, and can explain the limits. Do not claim production AI experience
or completed features from the roadmap.
