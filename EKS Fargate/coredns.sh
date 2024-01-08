#!/bin/bash
kubectl patch deployment coredns -n kube-system --type json --patch='[{\"op\": \"remove\", \"path\": \"/spec/template/metadata/annotations/eks.amazonaws.com~1compute-type\"}]'
