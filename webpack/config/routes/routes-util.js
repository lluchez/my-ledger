function cleanRoute(route) {
  return route.replace(/\/{2,}/g, '/')
}

// This will recursively map our format of routes to the format
// that react-router-config expects
export function convertCustomRouteConfig(routes, parentRoutePath = '') {
  return routes.map(({path, routes, ...routeOptions}) => {
    const pathResult = (typeof path === 'function') ? path(parentRoutePath || '') : `${parentRoutePath}/${path || ''}`
    return {
      path: cleanRoute(pathResult),
      routes: routes ? convertCustomRouteConfig(routes, pathResult) : [],
      ...routeOptions
    }
  })
}
