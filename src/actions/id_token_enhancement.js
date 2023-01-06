exports.onExecutePostLogin = async (event, api) => {
    console.log(event.request);
    if (event.client.client_id === '${client_id}') {
      const scopes = (event.request.query && event.request.query.scope) || (event.request.body && event.request.body.scope);
      var requestedScopes;
  
      const addressScopes = ["address"];
      if(scopes != null){
        requestedScopes = scopes.split(" ");
        requestedScopes.some((scope) => addressScopes.includes(scope));
      }
  
      if (requestedScopes || event.request.body.grant_type === 'refresh_token') {
        api.idToken.setCustomClaim("address_1", event.user.user_metadata.address_1);
        api.idToken.setCustomClaim("state", event.user.user_metadata.state);
        api.idToken.setCustomClaim("zip_code", event.user.user_metadata.zip_code);
        api.idToken.setCustomClaim("mobile", event.user.user_metadata.phone_number);
      }
    }
  };