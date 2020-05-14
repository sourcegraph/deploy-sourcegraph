src_create_first_admin("e2e@sourcegrah.com", "e2e-test-user", "123123123-e2e-test")

svc_config = {
      "url": "https://github.com",
      "token": src_context["github_token"],
      "orgs": [],
      "repos": [
         "sourcegraph-testing/zap"
       ]
}

svc_id = src_add_external_service("GITHUB", "e2e-test", svc_config)

cloned = src_wait_repo_cloned("github.com/sourcegraph-testing/zap", 5, 2)

if cloned:
   count = src_search_match_count("repo:^github.com/sourcegraph-testing/zap$ SugaredLogger count:99999")
   passed = count == 16
else:
   passed = False

src_delete_external_service(svc_id)

src_log("done")
