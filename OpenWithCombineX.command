#!/bin/sh

export SWIFT_PACKAGE_USE_COMBINEX="true"
killall Xcode || true
open $(dirname $0)/Package.swift
