---
name: vector-db-rag
description: >
  Use when implementing RAG pipelines: embeddings, vector stores, chunking, retrieval.
  Trigger: "RAG", "vector database", "embeddings", "semantic search", "pgvector",
  "chunking strategy", "retrieval augmented generation", "reranking".
license: MIT
metadata:
  author: Batuta
  version: "1.0"
  created: "2026-02-26"
  scope: [pipeline]
  auto_invoke:
    - "Implementing retrieval augmented generation (RAG)"
    - "Choosing embedding model or vector store"
    - "Designing chunking strategy for documents"
    - "Setting up pgvector for semantic search"
    - "Adding reranking or hybrid search"
    - "Evaluating RAG pipeline quality (hit rate, MRR)"
  platforms: [claude, antigravity]
allowed-tools: Read Edit Write Glob Grep Bash
---

# Vector DB & RAG -- Retrieval Augmented Generation for Batuta Projects

## Purpose

Standardize how Batuta projects implement RAG (Retrieval Augmented Generation) pipelines. This skill covers the full pipeline from document ingestion through chunking, embedding, storage in pgvector (our preferred vector store since Batuta already runs PostgreSQL), retrieval, and reranking. It prevents common RAG mistakes like oversized chunks that dilute relevance, missing multi-tenant vector isolation, and unmonitored retrieval quality.

## When to Use

- **During sdd-design**: When the solution involves semantic search, document Q&A, or knowledge base features
- **During sdd-apply**: When implementing the RAG pipeline components
- **Integration work**: When connecting RAG with LLM pipelines (see `llm-pipeline-design` skill)
- **On demand**: When evaluating or optimizing RAG pipeline quality

## Critical Patterns

### Pattern 1: pgvector with Multi-Tenant Isolation

pgvector is the default vector store because Batuta already uses PostgreSQL. Tenant isolation is achieved through PostgreSQL Row-Level Security (RLS), the same mechanism used for relational data.

```sql
-- BUSINESS RULE: Vectors live in the same PostgreSQL instance as relational data.
CREATE EXTENSION IF NOT EXISTS vector;

CREATE TABLE document_embeddings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id TEXT NOT NULL,
    document_id UUID NOT NULL REFERENCES documents(id) ON DELETE CASCADE,
    chunk_index INT NOT NULL,
    chunk_text TEXT NOT NULL,
    metadata JSONB DEFAULT '{}',
    embedding vector(1536),  -- OpenAI text-embedding-3-small
    created_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE (document_id, chunk_index)
);

-- SECURITY: RLS ensures tenants can only search their own vectors.
ALTER TABLE document_embeddings ENABLE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation ON document_embeddings
    USING (tenant_id = current_setting('app.current_tenant'));

-- HNSW index: m=16, ef_construction=64 is good for <1M vectors.
CREATE INDEX ON document_embeddings
    USING hnsw (embedding vector_cosine_ops) WITH (m = 16, ef_construction = 64);
```

### Pattern 2: Chunking Pipeline with Document-Type Routing

Different document types need different chunking strategies. Route by type, not one-size-fits-all.

```python
"""Type-aware chunking: different document types need different strategies."""
from langchain.text_splitter import RecursiveCharacterTextSplitter, MarkdownHeaderTextSplitter

# BUSINESS RULE: 256-512 tokens is the sweet spot; larger chunks dilute relevance.
CHUNKING_CONFIG = {
    "pdf":      {"splitter": RecursiveCharacterTextSplitter, "chunk_size": 512,
                 "chunk_overlap": 50, "separators": ["\n\n", "\n", ". ", " "]},
    "markdown": {"splitter": MarkdownHeaderTextSplitter,
                 "headers_to_split_on": [("#", "h1"), ("##", "h2"), ("###", "h3")]},
    "code":     {"splitter": RecursiveCharacterTextSplitter, "chunk_size": 1000,
                 "chunk_overlap": 100, "separators": ["\nclass ", "\ndef ", "\n\n", "\n"]},
    # WORKAROUND: Code needs larger chunks to preserve function boundaries.
}

def chunk_document(text: str, doc_type: str) -> list[dict]:
    """Split document using type-appropriate strategy. Returns list of chunk dicts."""
    config = {**CHUNKING_CONFIG.get(doc_type, CHUNKING_CONFIG["pdf"])}
    splitter = config.pop("splitter")(**config)
    return [{"text": c, "chunk_index": i, "metadata": {"doc_type": doc_type}}
            for i, c in enumerate(splitter.split_text(text))]
```

### Pattern 3: Hybrid Search (Semantic + Keyword)

Pure vector similarity misses exact matches (product codes, names). Hybrid search combines vector similarity with PostgreSQL full-text search for best results.

```python
"""Hybrid search: pgvector similarity + PostgreSQL full-text for exact keyword matches."""

async def hybrid_search(query: str, query_embedding: list[float],
                        tenant_id: str, limit: int = 10, semantic_weight: float = 0.7):
    """Combine semantic + keyword search. Pure vector misses exact matches (SKUs, names)."""
    # BUSINESS RULE: Combined scoring ensures exact keyword matches rank high.
    sql = """
    WITH semantic AS (
        SELECT id, chunk_text, metadata, 1 - (embedding <=> :embedding) AS sem_score
        FROM document_embeddings WHERE tenant_id = :tenant_id
        ORDER BY embedding <=> :embedding LIMIT :limit * 2
    ), keyword AS (
        SELECT id, chunk_text, metadata,
               ts_rank(to_tsvector('spanish', chunk_text),
                       plainto_tsquery('spanish', :query)) AS kw_score
        FROM document_embeddings WHERE tenant_id = :tenant_id
          AND to_tsvector('spanish', chunk_text) @@ plainto_tsquery('spanish', :query)
        LIMIT :limit * 2
    )
    SELECT COALESCE(s.id, k.id) AS id, COALESCE(s.chunk_text, k.chunk_text) AS chunk_text,
           (COALESCE(s.sem_score,0) * :sw + COALESCE(k.kw_score,0) * (1-:sw)) AS score
    FROM semantic s FULL OUTER JOIN keyword k ON s.id = k.id
    ORDER BY score DESC LIMIT :limit
    """
    return await db.fetch_all(sql, {"embedding": query_embedding,
        "tenant_id": tenant_id, "query": query, "limit": limit, "sw": semantic_weight})
```

## Decision Trees

### Vector Store Selection

| Situation | Store | Why |
|-----------|-------|-----|
| Already using PostgreSQL, <1M vectors | **pgvector** (default) | No extra infra, RLS for tenants, SQL joins with relational data |
| >5M vectors, need managed scaling | Pinecone | Managed service, auto-scaling, metadata filtering |
| Local development, prototyping | ChromaDB | Zero config, in-memory, fast iteration |
| Need full-text + vector in one query | **pgvector** + `tsvector` | Hybrid search without extra service |

### Embedding Model Selection

| Situation | Model | Dimensions | Why |
|-----------|-------|------------|-----|
| General purpose, good quality | OpenAI `text-embedding-3-small` | 1536 | Best cost/quality ratio |
| Maximum quality, cost not primary concern | OpenAI `text-embedding-3-large` | 3072 | Higher accuracy for critical use cases |
| Offline/air-gapped, no API dependency | `sentence-transformers/all-MiniLM-L6-v2` | 384 | Runs locally, no API costs |
| Spanish-language documents | `hiiamsid/sentence_similarity_spanish_es` | 768 | Trained on Spanish corpus |

### Retrieval Strategy Selection

| Situation | Strategy | Why |
|-----------|----------|-----|
| General Q&A, most use cases | Hybrid (semantic + keyword) | Best overall accuracy |
| Finding similar documents | Cosine similarity only | Semantic meaning matters, not exact terms |
| Known exact terms (SKUs, codes) | Keyword-first, semantic fallback | Exact match is more important |
| Diverse results needed | MMR (Maximal Marginal Relevance) | Reduces redundancy in results |
| High-stakes answers (medical, legal) | Retrieve + rerank (Cohere/cross-encoder) | Reranking improves top-k precision |

## Anti-Patterns (Never Do This)

| Anti-Pattern | Why It Is Wrong | Do This Instead |
|--------------|-----------------|-----------------|
| Storing vectors without tenant isolation | Tenant A can search Tenant B's documents | Use RLS on the embeddings table |
| One giant chunk per document (no splitting) | Retriever returns irrelevant context, LLM hallucinates | Split into 256-512 token chunks |
| Re-embedding on every query | Embeddings are expensive; document content rarely changes | Embed once at ingestion; re-embed only when content changes |
| Using cosine similarity without a threshold | Returns "best match" even when nothing is relevant (score 0.3) | Set minimum similarity threshold (0.7 for cosine) |
| Hardcoding embedding dimensions | Changing models requires schema migration | Store dimensions in config; use ALTER TABLE for migration |
| Skipping evaluation metrics | No way to know if retrieval is actually working | Track hit rate, MRR, and latency per query type |
| Embedding with wrong model for language | English models perform poorly on Spanish text | Use language-appropriate embedding model |

## Stack Integration

| Layer | Integration Point |
|-------|-------------------|
| **PostgreSQL** | pgvector extension; RLS for tenant isolation; GIN index for full-text |
| **LLM Pipeline** | Feed retrieved chunks to `llm-pipeline-design` skill's prompt templates |
| **Temporal Workers** | Background embedding jobs run as Temporal activities with retry |
| **Langfuse** | Track retrieval quality metrics alongside LLM generation quality |
| **FastAPI** | Search endpoints follow `api-design` skill conventions (cursor pagination, RFC 9457 errors) |

## Code Examples

```python
# Example: Embedding ingestion pipeline
async def ingest_document(document_id: str, text: str, doc_type: str, tenant_id: str):
    """Chunk, embed (batched), and store in pgvector. Re-embeds only on content change."""
    chunks = chunk_document(text, doc_type)
    # BUSINESS RULE: Batch embeddings to reduce API calls and cost.
    response = OpenAI().embeddings.create(
        input=[c["text"] for c in chunks], model="text-embedding-3-small")
    embeddings = [e.embedding for e in response.data]
    await db.execute("DELETE FROM document_embeddings WHERE document_id = :id", {"id": document_id})
    for chunk, emb in zip(chunks, embeddings):
        await db.execute(
            """INSERT INTO document_embeddings (tenant_id, document_id, chunk_index,
               chunk_text, metadata, embedding) VALUES (:t,:d,:i,:txt,:m,:e)""",
            {"t": tenant_id, "d": document_id, "i": chunk["chunk_index"],
             "txt": chunk["text"], "m": chunk["metadata"], "e": emb})
```

```python
# Example: RAG evaluation -- MUST run on 50+ labeled Q&A pairs before production
def evaluate_retrieval(test_set: list[dict], retriever, k: int = 5) -> dict:
    """Returns hit_rate, MRR, and avg_latency_ms over the test set."""
    hits, rrs, lats = 0, [], []
    for case in test_set:
        t0 = time.time()
        results = retriever(case["question"], limit=k)
        lats.append(time.time() - t0)
        rids = [r["document_id"] for r in results]
        relevant = set(case["relevant_doc_ids"])
        if relevant & set(rids): hits += 1
        rrs.append(next((1.0/i for i, r in enumerate(rids,1) if r in relevant), 0.0))
    n = len(test_set)
    return {"hit_rate": hits/n, "mrr": sum(rrs)/n, "avg_latency_ms": sum(lats)/n*1000}
```

## Commands

```bash
# Install pgvector extension
psql -c "CREATE EXTENSION IF NOT EXISTS vector;"

# Check pgvector version and index build progress
psql -c "SELECT extversion FROM pg_extension WHERE extname = 'vector';"
psql -c "SELECT phase, tuples_done, tuples_total FROM pg_stat_progress_create_index;"
```

## Rules

- MUST use pgvector as the default vector store (same PostgreSQL instance as relational data)
- MUST apply Row-Level Security on the embeddings table for multi-tenant isolation
- MUST use HNSW index (not IVFFlat) for production workloads -- better recall with minimal latency tradeoff
- MUST use hybrid search (semantic + keyword) as the default retrieval strategy
- MUST set a minimum similarity threshold (0.7 for cosine) -- never return irrelevant results
- MUST track evaluation metrics (hit rate, MRR) on a labeled test set before deploying to production
- MUST batch embedding API calls to reduce cost and latency
- MUST use document-type-aware chunking -- never apply one strategy to all document types
- NEVER store vectors without tenant_id -- this is a data isolation violation
- NEVER re-embed documents on every query -- embed at ingestion time only

## What This Means (Simply)

> **For non-technical readers**: RAG is how we give our AI a "knowledge library" to consult before answering questions. Instead of relying only on what the AI was trained on, we break our documents into small pieces (chunks), convert them into numerical representations (embeddings), and store them in a searchable database. When a user asks a question, we first search the library for relevant pieces, then give those pieces to the AI along with the question. This means the AI gives answers based on our actual documents, not guesses. The skill ensures we do this consistently, securely (each customer only searches their own documents), and with quality measurements so we know the system actually works.
