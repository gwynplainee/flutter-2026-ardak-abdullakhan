# NOTES

## Level 1: Postman

GET /users -> 200, application/json; charset=utf-8, list of 10 users.

GET /users/999 -> 404, body: {}

POST /users (JSON body) -> 201, body = what I sent + "id": 11 added by the server.

GET /users?id=3 -> 200, a LIST with one user (not an object).

### User (top level)
| field    | JSON type | Dart type | nullable? |
|----------|-----------|-----------|-----------|
| id       | number    | int       | no        |
| name     | string    | String    | no        |
| username | string    | String    | no        |
| email    | string    | String    | no        |
| phone    | string    | String    | no        |
| website  | string    | String?   | yes (present in all 10 users, but I treat it as optional on purpose) |
| address  | object    | Address   | no        |
| company  | object    | record ({String name, String catchPhrase}) | no |

### address
| field   | JSON type | Dart type | nullable? |
|---------|-----------|-----------|-----------|
| street  | string    | String    | no |
| suite   | string    | String    | no |
| city    | string    | String    | no |
| zipcode | string    | String    | no |
| geo     | object    | Geo       | no (nested twice: address.geo) |

### address.geo
| field | JSON type | Dart type | nullable? |
|-------|-----------|-----------|-----------|
| lat   | STRING ("-37.3159") | double (double.parse) | no |
| lng   | STRING ("81.1496")  | double (double.parse) | no |

### company
| field      | JSON type | Dart type | nullable? |
|------------|-----------|-----------|-----------|
| name       | string    | String    | no |
| catchPhrase| string    | String    | no |
| bs         | string    | (not used)| - |