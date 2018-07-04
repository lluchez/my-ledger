import { convertCustomRouteConfig } from './routes-util'
import {
  rootRoute, homeRoute, bankAccountsRoute, bankStatementsRoute, bankRecordsRoute, auditsRoute, statementParsersRoute
} from './routes-definitions'

const routes = [
  {
    ...rootRoute(),
    routes: [
      bankAccountsRoute(),
      bankStatementsRoute(),
      bankRecordsRoute(),
      auditsRoute(),
      statementParsersRoute(),
      homeRoute()
    ]
  }
]

export default convertCustomRouteConfig(routes)
