{ apiVersion = "apps/v1"
, kind = "Deployment"
, metadata =
  { annotations = None (List { mapKey : Text, mapValue : Text })
  , clusterName = None Text
  , creationTimestamp = None Text
  , deletionGracePeriodSeconds = None Natural
  , deletionTimestamp = None Text
  , finalizers = None (List Text)
  , generateName = None Text
  , generation = None Natural
  , labels = Some
    [ { mapKey = "app.kubernetes.io/name", mapValue = "jaeger" }
    , { mapKey = "app", mapValue = "jaeger" }
    , { mapKey = "app.kubernetes.io/component", mapValue = "all-in-one" }
    , { mapKey = "deploy", mapValue = "sourcegraph" }
    ]
  , managedFields =
      None
        ( List
            { apiVersion : Text
            , fieldsType : Optional Text
            , fieldsV1 : Optional (List { mapKey : Text, mapValue : Text })
            , manager : Optional Text
            , operation : Optional Text
            , time : Optional Text
            }
        )
  , name = Some "jaeger"
  , namespace = None Text
  , ownerReferences =
      None
        ( List
            { apiVersion : Text
            , blockOwnerDeletion : Optional Bool
            , controller : Optional Bool
            , kind : Text
            , name : Text
            , uid : Text
            }
        )
  , resourceVersion = None Text
  , selfLink = None Text
  , uid = None Text
  }
, spec = Some
  { minReadySeconds = None Natural
  , paused = None Bool
  , progressDeadlineSeconds = None Natural
  , replicas = Some 1
  , revisionHistoryLimit = None Natural
  , selector =
    { matchExpressions =
        None
          (List { key : Text, operator : Text, values : Optional (List Text) })
    , matchLabels = Some
      [ { mapKey = "app.kubernetes.io/name", mapValue = "jaeger" }
      , { mapKey = "app", mapValue = "jaeger" }
      , { mapKey = "app.kubernetes.io/component", mapValue = "all-in-one" }
      ]
    }
  , strategy = Some
    { rollingUpdate =
        None
          { maxSurge : Optional < Int : Natural | String : Text >
          , maxUnavailable : Optional < Int : Natural | String : Text >
          }
    , type = Some "Recreate"
    }
  , template =
    { metadata =
      { annotations = Some
        [ { mapKey = "prometheus.io/port", mapValue = "16686" }
        , { mapKey = "prometheus.io/scrape", mapValue = "true" }
        ]
      , clusterName = None Text
      , creationTimestamp = None Text
      , deletionGracePeriodSeconds = None Natural
      , deletionTimestamp = None Text
      , finalizers = None (List Text)
      , generateName = None Text
      , generation = None Natural
      , labels = Some
        [ { mapKey = "app.kubernetes.io/name", mapValue = "jaeger" }
        , { mapKey = "app", mapValue = "jaeger" }
        , { mapKey = "app.kubernetes.io/component", mapValue = "all-in-one" }
        ]
      , managedFields =
          None
            ( List
                { apiVersion : Text
                , fieldsType : Optional Text
                , fieldsV1 : Optional (List { mapKey : Text, mapValue : Text })
                , manager : Optional Text
                , operation : Optional Text
                , time : Optional Text
                }
            )
      , name = None Text
      , namespace = None Text
      , ownerReferences =
          None
            ( List
                { apiVersion : Text
                , blockOwnerDeletion : Optional Bool
                , controller : Optional Bool
                , kind : Text
                , name : Text
                , uid : Text
                }
            )
      , resourceVersion = None Text
      , selfLink = None Text
      , uid = None Text
      }
    , spec = Some
      { activeDeadlineSeconds = None Natural
      , affinity =
          None
            { nodeAffinity :
                Optional
                  { preferredDuringSchedulingIgnoredDuringExecution :
                      Optional
                        ( List
                            { preference :
                                { matchExpressions :
                                    Optional
                                      ( List
                                          { key : Text
                                          , operator : Text
                                          , values : Optional (List Text)
                                          }
                                      )
                                , matchFields :
                                    Optional
                                      ( List
                                          { key : Text
                                          , operator : Text
                                          , values : Optional (List Text)
                                          }
                                      )
                                }
                            , weight : Natural
                            }
                        )
                  , requiredDuringSchedulingIgnoredDuringExecution :
                      Optional
                        { nodeSelectorTerms :
                            List
                              { matchExpressions :
                                  Optional
                                    ( List
                                        { key : Text
                                        , operator : Text
                                        , values : Optional (List Text)
                                        }
                                    )
                              , matchFields :
                                  Optional
                                    ( List
                                        { key : Text
                                        , operator : Text
                                        , values : Optional (List Text)
                                        }
                                    )
                              }
                        }
                  }
            , podAffinity :
                Optional
                  { preferredDuringSchedulingIgnoredDuringExecution :
                      Optional
                        ( List
                            { podAffinityTerm :
                                { labelSelector :
                                    Optional
                                      { matchExpressions :
                                          Optional
                                            ( List
                                                { key : Text
                                                , operator : Text
                                                , values : Optional (List Text)
                                                }
                                            )
                                      , matchLabels :
                                          Optional
                                            ( List
                                                { mapKey : Text
                                                , mapValue : Text
                                                }
                                            )
                                      }
                                , namespaces : Optional (List Text)
                                , topologyKey : Text
                                }
                            , weight : Natural
                            }
                        )
                  , requiredDuringSchedulingIgnoredDuringExecution :
                      Optional
                        ( List
                            { labelSelector :
                                Optional
                                  { matchExpressions :
                                      Optional
                                        ( List
                                            { key : Text
                                            , operator : Text
                                            , values : Optional (List Text)
                                            }
                                        )
                                  , matchLabels :
                                      Optional
                                        ( List
                                            { mapKey : Text, mapValue : Text }
                                        )
                                  }
                            , namespaces : Optional (List Text)
                            , topologyKey : Text
                            }
                        )
                  }
            , podAntiAffinity :
                Optional
                  { preferredDuringSchedulingIgnoredDuringExecution :
                      Optional
                        ( List
                            { podAffinityTerm :
                                { labelSelector :
                                    Optional
                                      { matchExpressions :
                                          Optional
                                            ( List
                                                { key : Text
                                                , operator : Text
                                                , values : Optional (List Text)
                                                }
                                            )
                                      , matchLabels :
                                          Optional
                                            ( List
                                                { mapKey : Text
                                                , mapValue : Text
                                                }
                                            )
                                      }
                                , namespaces : Optional (List Text)
                                , topologyKey : Text
                                }
                            , weight : Natural
                            }
                        )
                  , requiredDuringSchedulingIgnoredDuringExecution :
                      Optional
                        ( List
                            { labelSelector :
                                Optional
                                  { matchExpressions :
                                      Optional
                                        ( List
                                            { key : Text
                                            , operator : Text
                                            , values : Optional (List Text)
                                            }
                                        )
                                  , matchLabels :
                                      Optional
                                        ( List
                                            { mapKey : Text, mapValue : Text }
                                        )
                                  }
                            , namespaces : Optional (List Text)
                            , topologyKey : Text
                            }
                        )
                  }
            }
      , automountServiceAccountToken = None Bool
      , containers =
        [ { args = Some [ "--memory.max-traces=20000" ]
          , command = None (List Text)
          , env =
              None
                ( List
                    { name : Text
                    , value : Optional Text
                    , valueFrom :
                        Optional
                          { configMapKeyRef :
                              Optional
                                { key : Text
                                , name : Optional Text
                                , optional : Optional Bool
                                }
                          , fieldRef :
                              Optional
                                { apiVersion : Optional Text, fieldPath : Text }
                          , resourceFieldRef :
                              Optional
                                { containerName : Optional Text
                                , divisor : Optional Text
                                , resource : Text
                                }
                          , secretKeyRef :
                              Optional
                                { key : Text
                                , name : Optional Text
                                , optional : Optional Bool
                                }
                          }
                    }
                )
          , envFrom =
              None
                ( List
                    { configMapRef :
                        Optional
                          { name : Optional Text, optional : Optional Bool }
                    , prefix : Optional Text
                    , secretRef :
                        Optional
                          { name : Optional Text, optional : Optional Bool }
                    }
                )
          , image = Some
              "sourcegraph/jaeger-all-in-one:3.15.0@sha256:5fa54e0ef24d0c4afea3616b892e83210a8ab8d0906d4bc604bbfdc6c90df30f"
          , imagePullPolicy = None Text
          , lifecycle =
              None
                { postStart :
                    Optional
                      { exec : Optional { command : Optional (List Text) }
                      , httpGet :
                          Optional
                            { host : Optional Text
                            , httpHeaders :
                                Optional (List { name : Text, value : Text })
                            , path : Optional Text
                            , port : < Int : Natural | String : Text >
                            , scheme : Optional Text
                            }
                      , tcpSocket :
                          Optional
                            { host : Optional Text
                            , port : < Int : Natural | String : Text >
                            }
                      }
                , preStop :
                    Optional
                      { exec : Optional { command : Optional (List Text) }
                      , httpGet :
                          Optional
                            { host : Optional Text
                            , httpHeaders :
                                Optional (List { name : Text, value : Text })
                            , path : Optional Text
                            , port : < Int : Natural | String : Text >
                            , scheme : Optional Text
                            }
                      , tcpSocket :
                          Optional
                            { host : Optional Text
                            , port : < Int : Natural | String : Text >
                            }
                      }
                }
          , livenessProbe =
              None
                { exec : Optional { command : Optional (List Text) }
                , failureThreshold : Optional Natural
                , httpGet :
                    Optional
                      { host : Optional Text
                      , httpHeaders :
                          Optional (List { name : Text, value : Text })
                      , path : Optional Text
                      , port : < Int : Natural | String : Text >
                      , scheme : Optional Text
                      }
                , initialDelaySeconds : Optional Natural
                , periodSeconds : Optional Natural
                , successThreshold : Optional Natural
                , tcpSocket :
                    Optional
                      { host : Optional Text
                      , port : < Int : Natural | String : Text >
                      }
                , timeoutSeconds : Optional Natural
                }
          , name = "jaeger"
          , ports = Some
            [ { containerPort = 5775
              , hostIP = None Text
              , hostPort = None Natural
              , name = None Text
              , protocol = Some "UDP"
              }
            , { containerPort = 6831
              , hostIP = None Text
              , hostPort = None Natural
              , name = None Text
              , protocol = Some "UDP"
              }
            , { containerPort = 6832
              , hostIP = None Text
              , hostPort = None Natural
              , name = None Text
              , protocol = Some "UDP"
              }
            , { containerPort = 5778
              , hostIP = None Text
              , hostPort = None Natural
              , name = None Text
              , protocol = Some "TCP"
              }
            , { containerPort = 16686
              , hostIP = None Text
              , hostPort = None Natural
              , name = None Text
              , protocol = Some "TCP"
              }
            , { containerPort = 14250
              , hostIP = None Text
              , hostPort = None Natural
              , name = None Text
              , protocol = Some "TCP"
              }
            ]
          , readinessProbe = Some
            { exec = None { command : Optional (List Text) }
            , failureThreshold = None Natural
            , httpGet = Some
              { host = None Text
              , httpHeaders = None (List { name : Text, value : Text })
              , path = Some "/"
              , port = < Int : Natural | String : Text >.Int 14269
              , scheme = None Text
              }
            , initialDelaySeconds = Some 5
            , periodSeconds = None Natural
            , successThreshold = None Natural
            , tcpSocket =
                None
                  { host : Optional Text
                  , port : < Int : Natural | String : Text >
                  }
            , timeoutSeconds = None Natural
            }
          , resources = Some
            { limits = Some
              [ { mapKey = "memory", mapValue = "1G" }
              , { mapKey = "cpu", mapValue = "1" }
              ]
            , requests = Some
              [ { mapKey = "memory", mapValue = "500M" }
              , { mapKey = "cpu", mapValue = "500m" }
              ]
            }
          , securityContext =
              None
                { allowPrivilegeEscalation : Optional Bool
                , capabilities :
                    Optional
                      { add : Optional (List Text)
                      , drop : Optional (List Text)
                      }
                , privileged : Optional Bool
                , procMount : Optional Text
                , readOnlyRootFilesystem : Optional Bool
                , runAsGroup : Optional Natural
                , runAsNonRoot : Optional Bool
                , runAsUser : Optional Natural
                , seLinuxOptions :
                    Optional
                      { level : Optional Text
                      , role : Optional Text
                      , type : Optional Text
                      , user : Optional Text
                      }
                , windowsOptions :
                    Optional
                      { gmsaCredentialSpec : Optional Text
                      , gmsaCredentialSpecName : Optional Text
                      , runAsUserName : Optional Text
                      }
                }
          , startupProbe =
              None
                { exec : Optional { command : Optional (List Text) }
                , failureThreshold : Optional Natural
                , httpGet :
                    Optional
                      { host : Optional Text
                      , httpHeaders :
                          Optional (List { name : Text, value : Text })
                      , path : Optional Text
                      , port : < Int : Natural | String : Text >
                      , scheme : Optional Text
                      }
                , initialDelaySeconds : Optional Natural
                , periodSeconds : Optional Natural
                , successThreshold : Optional Natural
                , tcpSocket :
                    Optional
                      { host : Optional Text
                      , port : < Int : Natural | String : Text >
                      }
                , timeoutSeconds : Optional Natural
                }
          , stdin = None Bool
          , stdinOnce = None Bool
          , terminationMessagePath = None Text
          , terminationMessagePolicy = None Text
          , tty = None Bool
          , volumeDevices = None (List { devicePath : Text, name : Text })
          , volumeMounts =
              None
                ( List
                    { mountPath : Text
                    , mountPropagation : Optional Text
                    , name : Text
                    , readOnly : Optional Bool
                    , subPath : Optional Text
                    , subPathExpr : Optional Text
                    }
                )
          , workingDir = None Text
          }
        ]
      , dnsConfig =
          None
            { nameservers : Optional (List Text)
            , options :
                Optional (List { name : Optional Text, value : Optional Text })
            , searches : Optional (List Text)
            }
      , dnsPolicy = None Text
      , enableServiceLinks = None Bool
      , ephemeralContainers =
          None
            ( List
                { args : Optional (List Text)
                , command : Optional (List Text)
                , env :
                    Optional
                      ( List
                          { name : Text
                          , value : Optional Text
                          , valueFrom :
                              Optional
                                { configMapKeyRef :
                                    Optional
                                      { key : Text
                                      , name : Optional Text
                                      , optional : Optional Bool
                                      }
                                , fieldRef :
                                    Optional
                                      { apiVersion : Optional Text
                                      , fieldPath : Text
                                      }
                                , resourceFieldRef :
                                    Optional
                                      { containerName : Optional Text
                                      , divisor : Optional Text
                                      , resource : Text
                                      }
                                , secretKeyRef :
                                    Optional
                                      { key : Text
                                      , name : Optional Text
                                      , optional : Optional Bool
                                      }
                                }
                          }
                      )
                , envFrom :
                    Optional
                      ( List
                          { configMapRef :
                              Optional
                                { name : Optional Text
                                , optional : Optional Bool
                                }
                          , prefix : Optional Text
                          , secretRef :
                              Optional
                                { name : Optional Text
                                , optional : Optional Bool
                                }
                          }
                      )
                , image : Optional Text
                , imagePullPolicy : Optional Text
                , lifecycle :
                    Optional
                      { postStart :
                          Optional
                            { exec : Optional { command : Optional (List Text) }
                            , httpGet :
                                Optional
                                  { host : Optional Text
                                  , httpHeaders :
                                      Optional
                                        (List { name : Text, value : Text })
                                  , path : Optional Text
                                  , port : < Int : Natural | String : Text >
                                  , scheme : Optional Text
                                  }
                            , tcpSocket :
                                Optional
                                  { host : Optional Text
                                  , port : < Int : Natural | String : Text >
                                  }
                            }
                      , preStop :
                          Optional
                            { exec : Optional { command : Optional (List Text) }
                            , httpGet :
                                Optional
                                  { host : Optional Text
                                  , httpHeaders :
                                      Optional
                                        (List { name : Text, value : Text })
                                  , path : Optional Text
                                  , port : < Int : Natural | String : Text >
                                  , scheme : Optional Text
                                  }
                            , tcpSocket :
                                Optional
                                  { host : Optional Text
                                  , port : < Int : Natural | String : Text >
                                  }
                            }
                      }
                , livenessProbe :
                    Optional
                      { exec : Optional { command : Optional (List Text) }
                      , failureThreshold : Optional Natural
                      , httpGet :
                          Optional
                            { host : Optional Text
                            , httpHeaders :
                                Optional (List { name : Text, value : Text })
                            , path : Optional Text
                            , port : < Int : Natural | String : Text >
                            , scheme : Optional Text
                            }
                      , initialDelaySeconds : Optional Natural
                      , periodSeconds : Optional Natural
                      , successThreshold : Optional Natural
                      , tcpSocket :
                          Optional
                            { host : Optional Text
                            , port : < Int : Natural | String : Text >
                            }
                      , timeoutSeconds : Optional Natural
                      }
                , name : Text
                , ports :
                    Optional
                      ( List
                          { containerPort : Natural
                          , hostIP : Optional Text
                          , hostPort : Optional Natural
                          , name : Optional Text
                          , protocol : Optional Text
                          }
                      )
                , readinessProbe :
                    Optional
                      { exec : Optional { command : Optional (List Text) }
                      , failureThreshold : Optional Natural
                      , httpGet :
                          Optional
                            { host : Optional Text
                            , httpHeaders :
                                Optional (List { name : Text, value : Text })
                            , path : Optional Text
                            , port : < Int : Natural | String : Text >
                            , scheme : Optional Text
                            }
                      , initialDelaySeconds : Optional Natural
                      , periodSeconds : Optional Natural
                      , successThreshold : Optional Natural
                      , tcpSocket :
                          Optional
                            { host : Optional Text
                            , port : < Int : Natural | String : Text >
                            }
                      , timeoutSeconds : Optional Natural
                      }
                , resources :
                    Optional
                      { limits :
                          Optional (List { mapKey : Text, mapValue : Text })
                      , requests :
                          Optional (List { mapKey : Text, mapValue : Text })
                      }
                , securityContext :
                    Optional
                      { allowPrivilegeEscalation : Optional Bool
                      , capabilities :
                          Optional
                            { add : Optional (List Text)
                            , drop : Optional (List Text)
                            }
                      , privileged : Optional Bool
                      , procMount : Optional Text
                      , readOnlyRootFilesystem : Optional Bool
                      , runAsGroup : Optional Natural
                      , runAsNonRoot : Optional Bool
                      , runAsUser : Optional Natural
                      , seLinuxOptions :
                          Optional
                            { level : Optional Text
                            , role : Optional Text
                            , type : Optional Text
                            , user : Optional Text
                            }
                      , windowsOptions :
                          Optional
                            { gmsaCredentialSpec : Optional Text
                            , gmsaCredentialSpecName : Optional Text
                            , runAsUserName : Optional Text
                            }
                      }
                , startupProbe :
                    Optional
                      { exec : Optional { command : Optional (List Text) }
                      , failureThreshold : Optional Natural
                      , httpGet :
                          Optional
                            { host : Optional Text
                            , httpHeaders :
                                Optional (List { name : Text, value : Text })
                            , path : Optional Text
                            , port : < Int : Natural | String : Text >
                            , scheme : Optional Text
                            }
                      , initialDelaySeconds : Optional Natural
                      , periodSeconds : Optional Natural
                      , successThreshold : Optional Natural
                      , tcpSocket :
                          Optional
                            { host : Optional Text
                            , port : < Int : Natural | String : Text >
                            }
                      , timeoutSeconds : Optional Natural
                      }
                , stdin : Optional Bool
                , stdinOnce : Optional Bool
                , targetContainerName : Optional Text
                , terminationMessagePath : Optional Text
                , terminationMessagePolicy : Optional Text
                , tty : Optional Bool
                , volumeDevices :
                    Optional (List { devicePath : Text, name : Text })
                , volumeMounts :
                    Optional
                      ( List
                          { mountPath : Text
                          , mountPropagation : Optional Text
                          , name : Text
                          , readOnly : Optional Bool
                          , subPath : Optional Text
                          , subPathExpr : Optional Text
                          }
                      )
                , workingDir : Optional Text
                }
            )
      , hostAliases =
          None (List { hostnames : Optional (List Text), ip : Optional Text })
      , hostIPC = None Bool
      , hostNetwork = None Bool
      , hostPID = None Bool
      , hostname = None Text
      , imagePullSecrets = None (List { name : Optional Text })
      , initContainers =
          None
            ( List
                { args : Optional (List Text)
                , command : Optional (List Text)
                , env :
                    Optional
                      ( List
                          { name : Text
                          , value : Optional Text
                          , valueFrom :
                              Optional
                                { configMapKeyRef :
                                    Optional
                                      { key : Text
                                      , name : Optional Text
                                      , optional : Optional Bool
                                      }
                                , fieldRef :
                                    Optional
                                      { apiVersion : Optional Text
                                      , fieldPath : Text
                                      }
                                , resourceFieldRef :
                                    Optional
                                      { containerName : Optional Text
                                      , divisor : Optional Text
                                      , resource : Text
                                      }
                                , secretKeyRef :
                                    Optional
                                      { key : Text
                                      , name : Optional Text
                                      , optional : Optional Bool
                                      }
                                }
                          }
                      )
                , envFrom :
                    Optional
                      ( List
                          { configMapRef :
                              Optional
                                { name : Optional Text
                                , optional : Optional Bool
                                }
                          , prefix : Optional Text
                          , secretRef :
                              Optional
                                { name : Optional Text
                                , optional : Optional Bool
                                }
                          }
                      )
                , image : Optional Text
                , imagePullPolicy : Optional Text
                , lifecycle :
                    Optional
                      { postStart :
                          Optional
                            { exec : Optional { command : Optional (List Text) }
                            , httpGet :
                                Optional
                                  { host : Optional Text
                                  , httpHeaders :
                                      Optional
                                        (List { name : Text, value : Text })
                                  , path : Optional Text
                                  , port : < Int : Natural | String : Text >
                                  , scheme : Optional Text
                                  }
                            , tcpSocket :
                                Optional
                                  { host : Optional Text
                                  , port : < Int : Natural | String : Text >
                                  }
                            }
                      , preStop :
                          Optional
                            { exec : Optional { command : Optional (List Text) }
                            , httpGet :
                                Optional
                                  { host : Optional Text
                                  , httpHeaders :
                                      Optional
                                        (List { name : Text, value : Text })
                                  , path : Optional Text
                                  , port : < Int : Natural | String : Text >
                                  , scheme : Optional Text
                                  }
                            , tcpSocket :
                                Optional
                                  { host : Optional Text
                                  , port : < Int : Natural | String : Text >
                                  }
                            }
                      }
                , livenessProbe :
                    Optional
                      { exec : Optional { command : Optional (List Text) }
                      , failureThreshold : Optional Natural
                      , httpGet :
                          Optional
                            { host : Optional Text
                            , httpHeaders :
                                Optional (List { name : Text, value : Text })
                            , path : Optional Text
                            , port : < Int : Natural | String : Text >
                            , scheme : Optional Text
                            }
                      , initialDelaySeconds : Optional Natural
                      , periodSeconds : Optional Natural
                      , successThreshold : Optional Natural
                      , tcpSocket :
                          Optional
                            { host : Optional Text
                            , port : < Int : Natural | String : Text >
                            }
                      , timeoutSeconds : Optional Natural
                      }
                , name : Text
                , ports :
                    Optional
                      ( List
                          { containerPort : Natural
                          , hostIP : Optional Text
                          , hostPort : Optional Natural
                          , name : Optional Text
                          , protocol : Optional Text
                          }
                      )
                , readinessProbe :
                    Optional
                      { exec : Optional { command : Optional (List Text) }
                      , failureThreshold : Optional Natural
                      , httpGet :
                          Optional
                            { host : Optional Text
                            , httpHeaders :
                                Optional (List { name : Text, value : Text })
                            , path : Optional Text
                            , port : < Int : Natural | String : Text >
                            , scheme : Optional Text
                            }
                      , initialDelaySeconds : Optional Natural
                      , periodSeconds : Optional Natural
                      , successThreshold : Optional Natural
                      , tcpSocket :
                          Optional
                            { host : Optional Text
                            , port : < Int : Natural | String : Text >
                            }
                      , timeoutSeconds : Optional Natural
                      }
                , resources :
                    Optional
                      { limits :
                          Optional (List { mapKey : Text, mapValue : Text })
                      , requests :
                          Optional (List { mapKey : Text, mapValue : Text })
                      }
                , securityContext :
                    Optional
                      { allowPrivilegeEscalation : Optional Bool
                      , capabilities :
                          Optional
                            { add : Optional (List Text)
                            , drop : Optional (List Text)
                            }
                      , privileged : Optional Bool
                      , procMount : Optional Text
                      , readOnlyRootFilesystem : Optional Bool
                      , runAsGroup : Optional Natural
                      , runAsNonRoot : Optional Bool
                      , runAsUser : Optional Natural
                      , seLinuxOptions :
                          Optional
                            { level : Optional Text
                            , role : Optional Text
                            , type : Optional Text
                            , user : Optional Text
                            }
                      , windowsOptions :
                          Optional
                            { gmsaCredentialSpec : Optional Text
                            , gmsaCredentialSpecName : Optional Text
                            , runAsUserName : Optional Text
                            }
                      }
                , startupProbe :
                    Optional
                      { exec : Optional { command : Optional (List Text) }
                      , failureThreshold : Optional Natural
                      , httpGet :
                          Optional
                            { host : Optional Text
                            , httpHeaders :
                                Optional (List { name : Text, value : Text })
                            , path : Optional Text
                            , port : < Int : Natural | String : Text >
                            , scheme : Optional Text
                            }
                      , initialDelaySeconds : Optional Natural
                      , periodSeconds : Optional Natural
                      , successThreshold : Optional Natural
                      , tcpSocket :
                          Optional
                            { host : Optional Text
                            , port : < Int : Natural | String : Text >
                            }
                      , timeoutSeconds : Optional Natural
                      }
                , stdin : Optional Bool
                , stdinOnce : Optional Bool
                , terminationMessagePath : Optional Text
                , terminationMessagePolicy : Optional Text
                , tty : Optional Bool
                , volumeDevices :
                    Optional (List { devicePath : Text, name : Text })
                , volumeMounts :
                    Optional
                      ( List
                          { mountPath : Text
                          , mountPropagation : Optional Text
                          , name : Text
                          , readOnly : Optional Bool
                          , subPath : Optional Text
                          , subPathExpr : Optional Text
                          }
                      )
                , workingDir : Optional Text
                }
            )
      , nodeName = None Text
      , nodeSelector = None (List { mapKey : Text, mapValue : Text })
      , overhead = None (List { mapKey : Text, mapValue : Text })
      , preemptionPolicy = None Text
      , priority = None Natural
      , priorityClassName = None Text
      , readinessGates = None (List { conditionType : Text })
      , restartPolicy = None Text
      , runtimeClassName = None Text
      , schedulerName = None Text
      , securityContext = Some
        { fsGroup = None Natural
        , runAsGroup = None Natural
        , runAsNonRoot = None Bool
        , runAsUser = Some 0
        , seLinuxOptions =
            None
              { level : Optional Text
              , role : Optional Text
              , type : Optional Text
              , user : Optional Text
              }
        , supplementalGroups = None (List Natural)
        , sysctls = None (List { name : Text, value : Text })
        , windowsOptions =
            None
              { gmsaCredentialSpec : Optional Text
              , gmsaCredentialSpecName : Optional Text
              , runAsUserName : Optional Text
              }
        }
      , serviceAccount = None Text
      , serviceAccountName = None Text
      , shareProcessNamespace = None Bool
      , subdomain = None Text
      , terminationGracePeriodSeconds = None Natural
      , tolerations =
          None
            ( List
                { effect : Optional Text
                , key : Optional Text
                , operator : Optional Text
                , tolerationSeconds : Optional Natural
                , value : Optional Text
                }
            )
      , topologySpreadConstraints =
          None
            ( List
                { labelSelector :
                    Optional
                      { matchExpressions :
                          Optional
                            ( List
                                { key : Text
                                , operator : Text
                                , values : Optional (List Text)
                                }
                            )
                      , matchLabels :
                          Optional (List { mapKey : Text, mapValue : Text })
                      }
                , maxSkew : Natural
                , topologyKey : Text
                , whenUnsatisfiable : Text
                }
            )
      , volumes =
          None
            ( List
                { awsElasticBlockStore :
                    Optional
                      { fsType : Optional Text
                      , partition : Optional Natural
                      , readOnly : Optional Bool
                      , volumeID : Text
                      }
                , azureDisk :
                    Optional
                      { cachingMode : Optional Text
                      , diskName : Text
                      , diskURI : Text
                      , fsType : Optional Text
                      , kind : Text
                      , readOnly : Optional Bool
                      }
                , azureFile :
                    Optional
                      { readOnly : Optional Bool
                      , secretName : Text
                      , shareName : Text
                      }
                , cephfs :
                    Optional
                      { monitors : List Text
                      , path : Optional Text
                      , readOnly : Optional Bool
                      , secretFile : Optional Text
                      , secretRef : Optional { name : Optional Text }
                      , user : Optional Text
                      }
                , cinder :
                    Optional
                      { fsType : Optional Text
                      , readOnly : Optional Bool
                      , secretRef : Optional { name : Optional Text }
                      , volumeID : Text
                      }
                , configMap :
                    Optional
                      { defaultMode : Optional Natural
                      , items :
                          Optional
                            ( List
                                { key : Text
                                , mode : Optional Natural
                                , path : Text
                                }
                            )
                      , name : Optional Text
                      , optional : Optional Bool
                      }
                , csi :
                    Optional
                      { driver : Text
                      , fsType : Optional Text
                      , nodePublishSecretRef : Optional { name : Optional Text }
                      , readOnly : Optional Bool
                      , volumeAttributes :
                          Optional (List { mapKey : Text, mapValue : Text })
                      }
                , downwardAPI :
                    Optional
                      { defaultMode : Optional Natural
                      , items :
                          Optional
                            ( List
                                { fieldRef :
                                    Optional
                                      { apiVersion : Optional Text
                                      , fieldPath : Text
                                      }
                                , mode : Optional Natural
                                , path : Text
                                , resourceFieldRef :
                                    Optional
                                      { containerName : Optional Text
                                      , divisor : Optional Text
                                      , resource : Text
                                      }
                                }
                            )
                      }
                , emptyDir :
                    Optional
                      { medium : Optional Text, sizeLimit : Optional Text }
                , fc :
                    Optional
                      { fsType : Optional Text
                      , lun : Optional Natural
                      , readOnly : Optional Bool
                      , targetWWNs : Optional (List Text)
                      , wwids : Optional (List Text)
                      }
                , flexVolume :
                    Optional
                      { driver : Text
                      , fsType : Optional Text
                      , options :
                          Optional (List { mapKey : Text, mapValue : Text })
                      , readOnly : Optional Bool
                      , secretRef : Optional { name : Optional Text }
                      }
                , flocker :
                    Optional
                      { datasetName : Optional Text
                      , datasetUUID : Optional Text
                      }
                , gcePersistentDisk :
                    Optional
                      { fsType : Optional Text
                      , partition : Optional Natural
                      , pdName : Text
                      , readOnly : Optional Bool
                      }
                , gitRepo :
                    Optional
                      { directory : Optional Text
                      , repository : Text
                      , revision : Optional Text
                      }
                , glusterfs :
                    Optional
                      { endpoints : Text
                      , path : Text
                      , readOnly : Optional Bool
                      }
                , hostPath : Optional { path : Text, type : Optional Text }
                , iscsi :
                    Optional
                      { chapAuthDiscovery : Optional Bool
                      , chapAuthSession : Optional Bool
                      , fsType : Optional Text
                      , initiatorName : Optional Text
                      , iqn : Text
                      , iscsiInterface : Optional Text
                      , lun : Natural
                      , portals : Optional (List Text)
                      , readOnly : Optional Bool
                      , secretRef : Optional { name : Optional Text }
                      , targetPortal : Text
                      }
                , name : Text
                , nfs :
                    Optional
                      { path : Text, readOnly : Optional Bool, server : Text }
                , persistentVolumeClaim :
                    Optional { claimName : Text, readOnly : Optional Bool }
                , photonPersistentDisk :
                    Optional { fsType : Optional Text, pdID : Text }
                , portworxVolume :
                    Optional
                      { fsType : Optional Text
                      , readOnly : Optional Bool
                      , volumeID : Text
                      }
                , projected :
                    Optional
                      { defaultMode : Optional Natural
                      , sources :
                          List
                            { configMap :
                                Optional
                                  { items :
                                      Optional
                                        ( List
                                            { key : Text
                                            , mode : Optional Natural
                                            , path : Text
                                            }
                                        )
                                  , name : Optional Text
                                  , optional : Optional Bool
                                  }
                            , downwardAPI :
                                Optional
                                  { items :
                                      Optional
                                        ( List
                                            { fieldRef :
                                                Optional
                                                  { apiVersion : Optional Text
                                                  , fieldPath : Text
                                                  }
                                            , mode : Optional Natural
                                            , path : Text
                                            , resourceFieldRef :
                                                Optional
                                                  { containerName :
                                                      Optional Text
                                                  , divisor : Optional Text
                                                  , resource : Text
                                                  }
                                            }
                                        )
                                  }
                            , secret :
                                Optional
                                  { items :
                                      Optional
                                        ( List
                                            { key : Text
                                            , mode : Optional Natural
                                            , path : Text
                                            }
                                        )
                                  , name : Optional Text
                                  , optional : Optional Bool
                                  }
                            , serviceAccountToken :
                                Optional
                                  { audience : Optional Text
                                  , expirationSeconds : Optional Natural
                                  , path : Text
                                  }
                            }
                      }
                , quobyte :
                    Optional
                      { group : Optional Text
                      , readOnly : Optional Bool
                      , registry : Text
                      , tenant : Optional Text
                      , user : Optional Text
                      , volume : Text
                      }
                , rbd :
                    Optional
                      { fsType : Optional Text
                      , image : Text
                      , keyring : Optional Text
                      , monitors : List Text
                      , pool : Optional Text
                      , readOnly : Optional Bool
                      , secretRef : Optional { name : Optional Text }
                      , user : Optional Text
                      }
                , scaleIO :
                    Optional
                      { fsType : Optional Text
                      , gateway : Text
                      , protectionDomain : Optional Text
                      , readOnly : Optional Bool
                      , secretRef : { name : Optional Text }
                      , sslEnabled : Optional Bool
                      , storageMode : Optional Text
                      , storagePool : Optional Text
                      , system : Text
                      , volumeName : Optional Text
                      }
                , secret :
                    Optional
                      { defaultMode : Optional Natural
                      , items :
                          Optional
                            ( List
                                { key : Text
                                , mode : Optional Natural
                                , path : Text
                                }
                            )
                      , optional : Optional Bool
                      , secretName : Optional Text
                      }
                , storageos :
                    Optional
                      { fsType : Optional Text
                      , readOnly : Optional Bool
                      , secretRef : Optional { name : Optional Text }
                      , volumeName : Optional Text
                      , volumeNamespace : Optional Text
                      }
                , vsphereVolume :
                    Optional
                      { fsType : Optional Text
                      , storagePolicyID : Optional Text
                      , storagePolicyName : Optional Text
                      , volumePath : Text
                      }
                }
            )
      }
    }
  }
, status =
    None
      { availableReplicas : Optional Natural
      , collisionCount : Optional Natural
      , conditions :
          Optional
            ( List
                { lastTransitionTime : Optional Text
                , lastUpdateTime : Optional Text
                , message : Optional Text
                , reason : Optional Text
                , status : Text
                , type : Text
                }
            )
      , observedGeneration : Optional Natural
      , readyReplicas : Optional Natural
      , replicas : Optional Natural
      , unavailableReplicas : Optional Natural
      , updatedReplicas : Optional Natural
      }
}
