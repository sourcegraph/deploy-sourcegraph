def validate():
    if cloned:
       count = src_search_match_count("repo:^github.com/sourcegraph-testing/repo-ssh-keys-test$ gallery-director-drone-vacant-blizzard")
       return count > 0
    else:
       return False

src_create_first_admin("e2e@sourcegrah.com", "e2e-test-user", "123123123-e2e-test")

svc_config = {
      "url": "https://github.com",
      "token": src_context["github_token"],
      "orgs": [],
      "repos": [
         "sourcegraph-testing/repo-ssh-keys-test"
       ]
}

svc_id = src_add_external_service("GITHUB", "e2e-test", svc_config)

cloned = src_wait_repo_cloned("github.com/sourcegraph-testing/repo-ssh-keys-test", 5, 2)

passed = validate()

src_delete_external_service(svc_id)

src_log("done")
