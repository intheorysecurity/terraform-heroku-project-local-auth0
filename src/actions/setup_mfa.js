exports.onExecutePostLogin = async (event, api) => {
  const sensitiveScopes = ["read:payment", "update:payment", "bill:payment"];

  //Enforce MFA on these operations
  function isSensitiveOperation() {
    const scopes =
      (event.request.query && event.request.query.scope) ||
      (event.request.body && event.request.body.scope);
    if (!scopes) {
      return false;
    }

    const requestedScopes = scopes.split(" ");
    return requestedScopes.some((scope) => sensitiveScopes.includes(scope));
  }

  function forceMFA() {
    api.multifactor.enable("any");
  }

  if (isSensitiveOperation()){
    forceMFA();
  }

};