# Implementing product events

Backend services should use the Rudderstack SDKs for sending data to the appropriate sources. Every backend services should have a ‘staging’ and ‘production’ Source in Rudderstack and use that Source’s configuration when sending tracking events Please coordinate this with the Data Team as Rudderstack permissions will need to be given out by them.

Telemetry events from the studios are merely events that get forwarded from the Telemetry-Sink service that captures those events and sends them to BQ and Amplitude.

## Server-side over Client-side

Generally, server-side events from backend services are preferred over client-side events from the telemetry service. Server-side events are more complete than client-side, and can include more metadata about the event without having to worry about client-side access to the metadata (e.g. internal data we wouldn’t want to leak outside our systems).

Client-side events should only be used when there is no server-side equivalent data. For example, logging commands used in the sanity cli tool can only be done client-side. However, it is important to remember that **all client-side evens are subject to telemetry consent status**. We will only receive events from users who have granted us consent (or who live outside the GDPR countries and have not set a consent status yet).

Currently, only about 55% of users of the CLI tool have granted consent, so we only receive 55% of all client-side events. This is why server-side events are preferred: server-side events are not subject to telemetry consent status.

## Event naming and shaping

- Events should be named in the format <Object> <Action>, e.g. `Document Published`, `Studio Entered` with the words capitalized
- `projectId` and `organizationId` should always be included if available
- Event properties from server-side should be in `camel_case` while event properties from client-side should be in `camelCase`
- Event property names should be unique to the event unless the property is common among all events
  - `trial_dialog_type` is preferred over `dialog_type` when it’s being used for the event `Trial Dialog Viewed`. Other events may also have a `dialog_type` property that doesn't make sense to aggregate with this event. Using unique names ensures that there will be no confusion when someone analyzes your event data.
  - `cli_version` is fine to use across events, since it’s typically the same regardless of the event type. If the property is likely to be used the same across multiple events, it is fine to use a more generic name and share that property.

Objects should be as flat as possible as Amplitude is not expecting deeply nested data. [There some cases where we manually handle this](https://github.com/sanity-io/rudderstack-transformations/blob/main/amplitude/amplitude.js#L414), but it involves actively transforming the data before it goes into Amplitude and we should strive to limit this as much as possible

Event definitions should be kept in files named `*.telemetry.ts`. This will auto-assign the @sanity-io/data-eng team as PR reviewers. The team should approve any PR changing the structure of a defined event.

## Using Staging vs. Production Environments

### Test Studio Telemetry Events in Staging

Running the studio locally without `SANITY_INTERNAL_ENV=staging` will be hitting all production endpoints for telemetry and events. If developing new events, please make sure you are on staging and check [staging telemetry-sink Rudderstack source](https://app.rudderstack.com/sources/2ZY2kbpy8iyb6KaeiC02fpKIygl) and the staging instance of Amplitude to see the incoming events you are developing.

Remember, hitting the `/v1/intake` production endpoint with arbitrary data will likely require an Amplitude admin to clean up the incorrect events. We’d like to limit this as much as possible so be sure to test event changes on staging!

### Updating Rudderstack Transformation

Rudderstack sources that are connected to the Amplitude destination are transformed by a JS function that is saved in Rudderstack. If adding new services or updating services, new entries may need to be explicitly added to an array of allowable events in the transformation script.

https://github.com/sanity-io/rudderstack-transformations

- The Amplitude transformation function that handles allowing certain events to flow to the destination and change them will has outgrown its setup and will have a better setup in the near future. Will update this doc and the repo as that progresses

The Amplitude transformation is used to reshape certain events and gate others from arriving in Amplitude. You can also filter and transform the properties you want in Amplitude here to conform with the event shapes Amplitude requires.

```typescript
    switch (activityLogAction) {
      case "organization.create":
        return {
		      userId: event.userId,
		      timestamp: Date.parse(event.properties.timestamp),
		      type: "track",
		      messageId: event.messageId,
		      request_ip: undefined,
          event: "Org Created",
          properties: {
            organization_name: event.properties.org_name,
            organization_id: event.properties.org_id,
          },
        };
```

The shape of the payload for a forwarded event to Amplitude looks like:

```typescript
 {
    userId: "g1234", // global sanity userId
    timestamp: 1729255007681, // epoch milliseconds
    type: "track", // event type is track, unless an identify call is needed for unknown users
    messageId: event.messageId, // forward from rudderstack source
    request_ip: undefined, // mark undefined for backend services unless forwarding IP from user manually
    event: "Org Created", // event name in Amplitude
      properties: { // snake_case fields, keep flat structure
        organization_name: "some org",
        organization_id: "o1234",
      },
    }
}
```

The transformation can be tested in the Rudderstack transformation editor where the transformation function is saved.

The repo holding the script transpiles the typescript files into a single file that exports the named function that Rudderstack will use to transform the event. If adding a new service, follow the patterns in the repo to add a new filter for the new source and do any rearranging of properties in an appropriate file. Be sure to also strip out the incoming IP address if the source is a backend one as it will report the location of the GCP data center otherwise: `request_ip: undefined` The file can be locally pasted into the [Rudderstack transformations dashboard](https://app.rudderstack.com/transformations) after it is built

## Verifying events are flowing properly

Initially you should double check that the SDK has been setup appropriately with the correct dataPlaneUrl and public key. If using the browser SDK, also double check you are specifying a subdomain and not leaking the cookie to the top-level domain and placing it on [api.sanity.io](http://api.sanity.io) calls.

Once set-up, you can call the event and see if it is flowing at several steps:

### 1. Check network requests from the app you are developing

- [Rudderstack SDKs](https://www.rudderstack.com/docs/sources/event-streams/sdks/)
- Backend SDKs will normally batch event sending
  - You may not see requests being sent immediately until the batch limit or timer is hit
- Be sure to flush the queue on graceful shutdowns!
- Front-end example

![image.png](../img/front-end-example.png)

### 2. Check “Live Events” from the Rudderstack Destination page

- In the upper-right of most destinations/sources in Rudderstack

![image.png](../img/rudderstack-sources-overview.png)

- Will open a 15-minute long live-view of the incoming data to the source or destination

![image.png](../img/rudderstack-live-preview.png)

- Also available on the Transformations edit page, allowing you to see the before/after of the data
- Good way to double check if your config is correctly set up and the properties you expect to be sent are going through

### 3. Check BQ staging dataset

- All sources are sent to BigQuery: `sanity-cloud.rudderstack_data_staging`
- fieldNames are automatically snake_cased here
- the event name will have its own table in this dataset

### 4. If targeting Amplitude, check Amplitude Staging environment

- Select the project **`sanity.work - Staging`**
- You can observe incoming events in the Live Events page

![image.png](../img/amplitude-events.png)

- You can also search for the userId you were testing with, the events for that user will be available in near realtime as well
