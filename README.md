# Bonfire.API.JSON

## Endpoints
* `POST /api/json/get-objects`

   give:
   ```
   curl -XPOST -Hcontent-type:application/json -d'{"ids": ["a", "b", "c"]}' http://localhost:4000/api/json/get-objects
   ```
   get:
   ```
   {"data": [{"__typename": "EconomicResource", "id": "a", ...}, {"__typename": "EconomicEvent", "id": "b", ...}, {"__typename": "Process", "id": "c", ...}, ...]}
   ```

* `POST /api/json/trace`

   give:
   ```
   curl -XPOST -Hcontent-type:application/json -d'{"id": "01FSBW06DKPMY3F51RXGWNVATN", "recurseLimit": 2}' http://localhost:4000/api/json/trace
   ```
   get:
   ```
   {"data": [{"__typename": "EconomicResource", "id": "a", ...}, {"__typename": "EconomicEvent", "id": "b", ...}, {"__typename": "Process", "id": "c", ...}, ...]}
   ```

* `POST /api/json/track`

   give:
   ```
   curl -XPOST -Hcontent-type:application/json -d'{"id": "01FSBW06DKPMY3F51RXGWNVATN", "recurseLimit": 2}' http://localhost:4000/api/json/track
   ```
   get:
   ```
   {"data": [{"__typename": "EconomicResource", "id": "a", ...}, {"__typename": "EconomicEvent", "id": "b", ...}, {"__typename": "Process", "id": "c", ...}, ...]}
   ```

## Unwinding

If you need the data to be not wrapped within an object with the `data`
key, you can pass the `unwind` boolean option with `true` value:

* `POST /api/json/get-objects`

   give:
   ```
   curl -XPOST -Hcontent-type:application/json -d'{"unwind": true, "ids": ["a", "b", "c"]}' http://localhost:4000/api/json/get-objects
   ```
   get:
   ```
   [{"__typename": "EconomicResource", "id": "a", ...}, {"__typename": "EconomicEvent", "id": "b", ...}, {"__typename": "Process", "id": "c", ...}, ...]
   ```
