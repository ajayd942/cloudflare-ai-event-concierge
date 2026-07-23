# Detailed Design Decision and Requirement Coverage

Status: Proposed for owner approval under [AJA-7](https://linear.app/ajayd94/issue/AJA-7/seed-34-produce-the-detailed-design-and-assurance-package)

## Reading the matrix

Ranges are inclusive and account for every identifier between their endpoints;
there are no omitted IDs. `Specified` means this package turns the approved
decision into an implementation/test/operations contract. `Owner input` means
the behavior is fixed but its environment-specific value/action remains
human-supplied. `Superseded` is used only for an explicit accepted ADR.

No approved product/HLD decision is intentionally superseded by AJA-7.
ADR-0008 refines the HLD's delegated coordinator choice while preserving KV as
content authority and the one-Worker/Free-only boundary.

## Approved planning baseline

| Decision IDs | Disposition | Detailed-design evidence |
|---|---|---|
| P-01–P-03 | Specified | [LLD invariants/scope](detailed-design.md#design-invariants), [data boundaries](security.md#data-and-trust-boundaries) |
| P-04–P-05 | Specified | [Content/presentation rules](data-model.md#presentation), [administration safety](administration.md#safety-rules) |
| P-06–P-07 | Specified; host release is owner input | [Deployment topology/release sequence](deployment.md#deployment-sequence) |
| P-08 | Preserved | No license change in this documentation package |
| P-09–P-10 | Specified | [Retrieval input](retrieval-design.md#outcome-and-invariants), [failure/release posture](evaluation-strategy.md#release-gates) |
| G-01–G-09 | Preserved | [Document control](detailed-design.md#document-control), [authority](deployment.md#authority), AJA-7 work/PR boundary |
| G-10 | Superseded only for the local runner by accepted [ADR-0001](adr/0001-run-symphony-with-danger-full-access.md); product credential boundary preserved | [Security secret policy](security.md#secret-and-configuration-policy) |
| G-11–G-14 | Preserved/owner input | [Deployment authority](deployment.md#authority), [human inputs](detailed-design.md#human-authority-and-open-inputs) |
| R-01–R-05 | Specified for implementation | [Module and typed boundaries](detailed-design.md#deployable-and-module-boundaries) |
| R-06–R-08 | Specified at interface/asset level | [Deployment build artifact](deployment.md#build-artifact), [browser matrix](evaluation-strategy.md#browser-and-accessibility) |
| R-09–R-13 | Specified as future bootstrap/check policy | [Test layers](evaluation-strategy.md#test-layers), [CI/CD](deployment.md#cicd-boundaries) |
| D-01–D-07 | Specified; resource IDs/compatibility date are owner input | [Environment topology/configuration](deployment.md#environment-topology) |
| D-08–D-09 | Specified; infrastructure actions are owner-only | [Authority](deployment.md#authority), [cost policy](cost-model.md#policy) |
| C-01–C-04 | Specified | [KV authority/key registry](data-model.md#kv-key-registry) |
| C-05–C-10 | Specified | [Identifiers/draft/published schemas](data-model.md#identifier-formats) |
| C-11–C-14 | Specified | [Entry/document bounds and retention](data-model.md#content-entry), [KV registry](data-model.md#kv-key-registry) |
| U-01–U-04 | Specified | [Publish state machine](detailed-design.md#publish-and-rollback-state-machine), [ADR-0008](adr/0008-use-durable-object-publish-coordinator.md) |
| U-05–U-07 | Specified | [Publish checkpoints](detailed-design.md#publish-checkpoints), [embedding template](retrieval-design.md#document-embedding-template) |
| U-08–U-11 | Specified | [Rollback differences](detailed-design.md#rollback-differences), [admin/runbooks](administration.md#rollback-content) |
| V-01–V-04 | Specified | [Embedding manifest/template](data-model.md#published-document), [retrieval model contract](retrieval-design.md#document-embedding-template) |
| V-05–V-07 | Specified | [Vectorize record](data-model.md#vectorize-record) |
| V-08–V-11 | Specified | [Template/tokenizer/query/migration](retrieval-design.md#document-embedding-template), [migration runbook](runbooks/embedding-migration.md) |
| H-01–H-05 | Specified | [Normalization/lexical/calibration/fusion](retrieval-design.md#text-normalization) |
| H-06–H-09 | Specified | [Grounding decision/failures](retrieval-design.md#grounding-decision) |
| H-10–H-13 | Specified | [Diagnostics/query/prompt](retrieval-design.md#retrieval-diagnostics) |
| A-01–A-05 | Specified; model promotion is owner-approved | [Prompt/provider contract](retrieval-design.md#grounded-prompt-contract) |
| A-06–A-09 | Specified | [Query/context/output/failure bounds](retrieval-design.md#semantic-query) |
| A-10–A-12 | Specified | [Prompt version, response validation, no prompt cache](retrieval-design.md#grounded-prompt-contract) |
| API-01–API-03 | Specified | [API route contract](api-contract.md) |
| API-04–API-06 | Specified | [Chat request and bounds](api-contract.md#post-apiv1chat) |
| API-07–API-10 | Specified | [Chat response/error/health](api-contract.md#public-api) |
| API-11–API-12 | Specified | [Config ETag/cache and draft ETag/concurrency](api-contract.md#get-apiv1config), [draft concurrency](detailed-design.md#draft-save-concurrency) |
| K-01–K-06 | Specified | [Cache policy/key/TTL/exclusions](detailed-design.md#cache-policy) |
| S-01–S-05 | Specified; actual origins/Access values/identities are owner input | [CORS/CSRF and JWT validation](security.md#access-jwt-validation) |
| S-06–S-10 | Specified; secrets/budgets/WAF settings are owner input | [Turnstile and abuse controls](security.md#turnstile-lifecycle) |
| S-11–S-13 | Specified | [Rendering/link/header policy](security.md#browser-rendering-link-and-header-policy) |
| S-14–S-18 | Specified; secrets/retention truth are owner input | [Secrets/privacy/supply-chain threats](security.md#secret-and-configuration-policy) |
| M-01–M-04 | Specified | [Admin middleware/API/save guide](detailed-design.md#admin-order), [administration](administration.md) |
| M-05–M-07 | Specified | [Preview/publish/status](administration.md#preview) |
| M-08–M-10 | Specified | [Rollback/import-export/runtime](administration.md#rollback-content) |
| W-01–W-05 | Specified at contract/test level | [Build artifact](deployment.md#build-artifact), [API/Turnstile behavior](api-contract.md) |
| W-06–W-10 | Specified; wedding release is owner input/outside this repo | [Browser/performance gates](evaluation-strategy.md#browser-and-accessibility), [deployment release order](deployment.md#deployment-sequence) |
| T-01–T-06 | Specified | [Dataset/metrics/test layers](evaluation-strategy.md) |
| T-07–T-09 | Specified | [Browser/performance targets](evaluation-strategy.md#performance-targets) |
| T-10–T-12 | Specified | [Failure injection and provider-load boundary](evaluation-strategy.md#failure-injection) |
| CI-01–CI-02 | Specified for future bootstrap; enforcement is owner/repository input | [PR CI boundary](deployment.md#pull-request) |
| CI-03–CI-05 | Specified | [Staging/production/content separation](deployment.md#cicd-boundaries) |
| CI-06–CI-09 | Specified; credentials/production approval are owner input | [Release record/authority](deployment.md#release-record) |
| O-01–O-04 | Specified | [Observability contract](detailed-design.md#observability-contract), [cost telemetry](cost-model.md#cost-telemetry) |
| O-05–O-06 | Specified; monitor destination/production actions are owner input | [Monitoring/kill switches](deployment.md#monitoring) |
| O-07–O-08 | Specified; backup location/custodian are owner input | [Runbook index](runbooks/README.md), [backup design](deployment.md#backup-and-recovery) |
| Q-01–Q-03 | Specified; provider limits/alerts are owner input | [Cost policy/thresholds](cost-model.md#budget-allocation-and-thresholds) |
| Q-04–Q-06 | Specified | [Per-path formulas and revalidation](cost-model.md#per-request-resource-path) |
| F-01–F-02 | Specified | This package and [ADR-0008](adr/0008-use-durable-object-publish-coordinator.md) |
| F-03–F-05 | Preserved for later measured implementation/portfolio work | [Evidence policy](evaluation-strategy.md#evidence-policy) |
| F-06 | Specified | [Known operational behavior](troubleshooting.md), product limitations remain unchanged |

## Product requirement coverage

| Requirement IDs | Evidence |
|---|---|
| PR-PUB-01–PR-PUB-08 | [Public API](api-contract.md#public-api), [grounding](retrieval-design.md#grounding-decision), [browser/release tests](evaluation-strategy.md#browser-and-accessibility) |
| PR-RAG-01–PR-RAG-06 | [Data authority](data-model.md#authority-and-canonical-encoding), [retrieval](retrieval-design.md), [cache](detailed-design.md#cache-policy) |
| PR-ADM-01–PR-ADM-08 | [Admin API](api-contract.md#admin-api), [administration guide](administration.md), [publish/rollback state](detailed-design.md#publish-and-rollback-state-machine) |
| PR-INT-01–PR-INT-03 | [Deployment release sequence](deployment.md#deployment-sequence), [browser/performance gates](evaluation-strategy.md#browser-and-accessibility) |
| PR-EVD-01–PR-EVD-04 | This traceable package, honest target/evidence policy, cost/release limitations, and future measured-evidence gates |

## Owner-supplied inputs

The package fixes how each input is validated/used but does not guess:

- Cloudflare account/zone/resource/Durable Object identifiers;
- Access issuer/audience and approved admin identities;
- production origins and whether `www` is canonical;
- production content and approved link hosts;
- Turnstile, Anthropic, rate-key, deployment, and notification secrets/settings;
- spending limits and provider alert capabilities;
- monitoring destination and encrypted backup location/custodian;
- wedding repository/deployment access; or
- production merge/deploy/publish/enable/rollback/pause/decommission decisions.

Their absence blocks the relevant environment action, not approval of the
behavioral design. No implementation issue is created or dispatched by AJA-7.
