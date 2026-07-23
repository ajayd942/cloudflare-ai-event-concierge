# Unexpected Spend and Quota Runbook

Status: Proposed; budgets, billing, provider limits, traffic policy, and
production state are owner-only.

## Triggers

- 50%, 80%, or 100% budget/usage threshold;
- abnormal Claude tokens/retries, Workers AI neurons, Vectorize dimensions, KV/
  Durable Object operations, or dynamic requests;
- forecast normal monthly operation above USD 5;
- any Cloudflare Free quota pressure or provider billing anomaly.

## Procedure

1. Record environment, UTC window, provider dimension, threshold, aggregate
   route/response-mode/cache/retry data, and current code/content versions.
2. At 80% or credible runaway risk, owner disables runtime and wedding feature
   flag. At hard-limit/100%, keep them off.
3. Confirm Anthropic project limit/alerts and Cloudflare plan remain as approved.
   Do not raise limits, add payment, or upgrade Workers automatically.
4. Identify from metadata whether traffic, cache misses, semantic queries,
   retries, publishing/preview, or a configuration regression dominates.
5. Verify WAF/app rate controls, Turnstile, cache eligibility, canonical/
   unsupported no-Claude paths, output/context/time bounds, and provider retry
   policy.
6. Contain with the narrowest owner-approved action: keep disabled, pause
   preview/publishing, correct a regression, or tighten non-breaking controls
   after review.
7. Reforecast using current official pricing/limits and measured usage.
8. Re-enable only after an approved correction stays below thresholds in
   staging/controlled production evidence.
9. Record cause, financial exposure from provider invoice/dashboard, actions,
   and next review without visitor identity/content.

If the service cannot remain safe/useful within Free Cloudflare and USD 5 normal
operation, the owner pauses, redesigns, or decommissions. Availability does not
authorize paid Workers.
