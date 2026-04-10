---
name: create-tracking-events
description: Guidelines for implementing product analytics events at Sanity. Use when adding telemetry, tracking user actions, implementing analytics, or sending events to Rudderstack, Amplitude, or BigQuery.
metadata:
  author: sanity
  version: "1.0"
---

# Event Tracking Guidelines

Use this skill when implementing product analytics, telemetry events, or user action tracking in Sanity services.

## Key Principles

### Server-side over Client-side

Always prefer server-side events from backend services over client-side events. Server-side events:

- Are more complete and can include internal metadata
- Are **not** subject to telemetry consent status
- Client-side events only capture ~55% of users (those who granted consent)

Use client-side events only when there is no server-side equivalent (e.g., CLI commands).

### Event Naming

Use the format `<Object> <Action>` with capitalized words:

- `Document Published`
- `Studio Entered`
- `Trial Dialog Viewed`
- `Organization Created`

### Required Properties

Always include these properties if available:

- `projectId`
- `organizationId`

### Property Naming Conventions

| Source      | Convention   | Example             |
| ----------- | ------------ | ------------------- |
| Server-side | `snake_case` | `trial_dialog_type` |
| Client-side | `camelCase`  | `trialDialogType`   |

### Property Uniqueness

Use event-specific property names to avoid aggregation confusion:

- Prefer: `trial_dialog_type` for `Trial Dialog Viewed`
- Avoid: generic `dialog_type` that could conflict with other events

Exception: Common properties like `cli_version` can be shared across events.

### Keep Payloads Flat

Amplitude does not handle deeply nested data well. Keep event properties as flat as possible.

## File Organization

Define event schemas in files named `*.telemetry.ts`. This automatically assigns `@sanity-io/data-eng` as PR reviewers for any changes.

## Frontend Analytics (@sanity/frontend-analytics)

For client-side tracking in React applications, use the `@sanity/frontend-analytics` package.

### Initialization (React)

1. Add `<AnalyticsInit />` component at app root:

   ```tsx
   import { AnalyticsInit } from "@sanity/frontend-analytics";

   <AnalyticsInit
     config={{
       writeKey: "your-rudderstack-write-key",
       dataPlaneUrl: "https://...",
       configUrl: "https://...",
       cookieDomain: "app.sanity.io", // Must be specific subdomain
       applicationName: "YourAppName",
       amplitude: false, // Global default for Amplitude routing
       debug: false, // Enable for console logging during development
     }}
   />;
   ```

2. Use `analyticsClient` anywhere in your app:

   ```tsx
   import { analyticsClient } from "@sanity/frontend-analytics";

   analyticsClient.track("Add Studio Button Clicked", {
     projectId: "something",
   });
   ```

### Waiting for Initialization

The `analyticsClient` queues events automatically, but if you need to ensure analytics is ready:

```tsx
// Check synchronously
if (analyticsClient.isReady) {
  // Analytics is initialized
}

// Wait asynchronously
await analyticsClient.ready();
```

### Amplitude Flag

Control whether events are sent to Amplitude:

- **Global default**: Set `amplitude: true` in config to send all events to Amplitude
- **Per-event override**: Pass 4th parameter to `track()`:

  ```tsx
  // Send to Amplitude even if global default is false
  analyticsClient.track("Important Action", props, undefined, true);

  // Skip Amplitude even if global default is true
  analyticsClient.track("Debug Event", props, undefined, false);
  ```

### Debug Mode

Enable `debug: true` in config during development to log all tracking calls to the console. This helps verify events are being sent with the correct properties before testing in Rudderstack/Amplitude staging.

### Cookie Domain Validation

The `cookieDomain` must be a specific subdomain to prevent cookie leakage:

- Valid: `app.sanity.io`, `manage.sanity.io`
- Invalid: `sanity.io`, `.sanity.work` (throws error)
- Exception: `localhost` is allowed for development

## Frontend Best Practices

### Type-Safe Event Definitions

Define allowed events as TypeScript union types, grouped by feature area:

```typescript
// Group events by feature
type TrialDialogEvents =
  | "Trial Dialog Viewed"
  | "Trial Dialog Dismissed"
  | "Trial Dialog CTA Clicked";

type PlanTabEvents =
  | "Change Plan Flow Initiated"
  | "Change Plan Flow Completed"
  | "Plan Downgraded";

// Combine into single allowed actions type
type AllowedActions = TrialDialogEvents | PlanTabEvents;
```

### Helper Function Wrappers

Create wrapper functions to enforce consistent tracking patterns:

```typescript
// Standard tracking helper
export function sendTrackingEvent(
  action: AllowedActions,
  projectId?: string,
  organizationId?: string,
  extraAttrs = {},
  amplitude = false,
): void {
  analyticsClient.track(
    action,
    { projectId, organizationId, ...extraAttrs },
    {},
    amplitude,
  );
}

// Amplitude convenience wrapper
export function sendAmplitudeTrackingEvent(
  action: AllowedActions,
  projectId?: string,
  organizationId?: string,
  extraAttrs = {},
): void {
  sendTrackingEvent(action, projectId, organizationId, extraAttrs, true);
}
```

### Domain-Specific Event Helpers

For complex events with many properties, create dedicated helpers with typed parameters:

```typescript
export function sendPlanChangeFailedEvent({
  currentPlan,
  targetPlan,
  errorMessage,
  projectId,
  orgId,
}: {
  currentPlan: Plan | undefined;
  targetPlan: Plan;
  errorMessage: string;
  projectId?: string;
  orgId?: string;
}): void {
  sendAmplitudeTrackingEvent("Change Plan Failed", projectId, orgId, {
    isUpgrade: currentPlan?.planTypeId === "free",
    targetPlan: targetPlan.id,
    currentPlan: currentPlan?.id,
    errorMessage,
  });
}
```

### Source Attribution

Capture the `ref` query parameter to track where users came from:

```typescript
const source = new URL(window.location.href).searchParams.get("ref") || "";
analyticsClient.track(action, {
  projectId,
  organizationId,
  source,
  ...extraAttrs,
});
```

## Testing Events

1. **Use staging environment**: Set `SANITY_INTERNAL_ENV=staging` when developing locally
2. **Never send test events to production** - requires admin cleanup

### Verification Steps

1. Check network requests from your app (backend SDKs batch requests)
2. Check "Live Events" in Rudderstack source/destination pages
3. Query `sanity-cloud.rudderstack_data_staging` in BigQuery
4. Check Amplitude staging (`sanity.work - Staging` project)

## References

For detailed implementation guides and architecture:

- [Implementing Product Events](references/implementing-product-events.md) - SDK setup, Rudderstack transformations, payload examples
- [Stack Overview](references/stack-overview.md) - Data pipeline architecture, BigQuery, Amplitude, Looker
