#!/usr/bin/env python3

"""This program configures which language servers to run"""

import os
import re
import subprocess
import shutil

lsp_proxy_env = {
    'go': {
        'LANGSERVER_GO': 'tcp://xlang-go:4389',
        'LANGSERVER_GO_BG': 'tcp://xlang-go-bg:4389'
    },
    'java': {
        'LANGSERVER_JAVA': 'tcp://xlang-java:2088',
        'LANGSERVER_JAVA_BG': 'tcp://xlang-java-bg:2088'
    },
    'php': {
        'LANGSERVER_PHP': 'tcp://xlang-php:2088',
        'LANGSERVER_PHP_BG': 'tcp://xlang-php:2088'
    },
    'python': {
        'LANGSERVER_PYTHON': 'tcp://xlang-python:2087',
        'LANGSERVER_PYTHON_BG': 'tcp://xlang-python:2087'
    },
    'typescript': {
        'LANGSERVER_JAVASCRIPT': 'tcp://xlang-typescript:2088',
        'LANGSERVER_JAVASCRIPT_BG': 'tcp://xlang-typescript-bg:2088',
        'LANGSERVER_TYPESCRIPT': 'tcp://xlang-typescript:2088',
        'LANGSERVER_TYPESCRIPT_BG': 'tcp://xlang-typescript-bg:2088'
    },
}

def main():
    cwd = os.path.join(os.path.dirname(os.path.realpath(__file__)), '..', '..')
    os.chdir(cwd)

    base = os.environ.get('BASE', 'base')

    if 'LANGUAGE_SERVERS' not in os.environ:
        langservers = input('Language servers (e.g. go,java,javascript,php,python,typescript) [none]: ')
    else:
        langservers = os.environ['LANGUAGE_SERVERS']

    if 'EXPERIMENTAL_LANGUAGE_SERVERS' not in os.environ:
        experimental = input('Experimental language servers (e.g. bash,clojure,cpp,cs,css,dockerfile,elixir,html,lua,ocaml,r,ruby,rust) [none]: ')
    else:
        experimental = os.environ['EXPERIMENTAL_LANGUAGE_SERVERS']

    lsp_proxy_deployment = os.path.join(base, 'lsp-proxy', 'lsp-proxy.Deployment.yaml')

    # Start clean
    shutil.rmtree(os.path.join(base, 'xlang'), ignore_errors=True)

    # TODO(jq 1.6): should be able to do this with a single command, but there is a bug in jq 1.5 that prevents us from using startswith.
    # https://github.com/stedolan/jq/issues/1146
    # Instead, we detect the exact environment variable names that we need to delete from the file and then delete them in a loop.
    with open(lsp_proxy_deployment) as fd:
        content = fd.read()
        matches = re.findall('(LANGSERVER_[A-Z_]+)', content)
    for match in matches:
        yq(lsp_proxy_deployment, '(.spec.template.spec.containers[] | select(.name == "lsp-proxy").env) |= del(.[] | select(.name == "'+match+'"))')

    langs = re.split("[ ,\t\n]+", langservers)
    for lang in langs:
        lang = lang.lower()
        if lang == '':
            continue
        if lang == "javascript":
            if "typescript" in langs:
                continue
            lang = "typescript"

        # Install the language server
        shutil.copytree(os.path.join('configure', 'xlang', lang), os.path.join(base, 'xlang', lang))

        # Update lsp-proxy configuration
        env_vars = lsp_proxy_env[lang]
        for key, value in env_vars.items():
            yq(lsp_proxy_deployment, '(.spec.template.spec.containers[] | select(.name == "lsp-proxy").env) += [{name: "'+key+'", value: "'+value+'"}]')
        
        if lang == "typescript":
            print("> Configured typescript and javascript (same language server)")
        else:
            print("> Configured " + lang)

    for lang in re.split("[ ,\t\n]+", experimental):
        lang = lang.lower()
        if lang == '':
            continue

        # Install the language server
        shutil.copytree(os.path.join('configure', 'xlang', 'experimental', lang), os.path.join(base, 'xlang', 'experimental', lang))

        # Update lsp-proxy configuration
        yq(lsp_proxy_deployment, '(.spec.template.spec.containers[] | select(.name == "lsp-proxy").env) += [{name: "LANGSERVER_'+lang.upper()+'", value: "tcp://xlang-'+lang+':8080"}]')
        
        print("> Configured " + lang)
    
    # Reconfigure in case Go was enabled because it needs the correct config-file name.
    subprocess.check_call(['./configure/config-file.sh'])
        

def yq(file, query):
    env = os.environ.copy()
    env['INFILE'] = file
    env['OUTFILE'] = file
    env['QUERY'] = query
    subprocess.check_call(['./configure/util/yq.sh'], env=env)

if __name__ == '__main__':
    main()
