//go:build !dynamic
// +build !dynamic

package rnnoise_android

//#cgo CFLAGS: -I${SRCDIR}/include
//#cgo CXXFLAGS: -I${SRCDIR}/include
//#cgo android,arm LDFLAGS: ${SRCDIR}/libs/librnnoise-android-armv7a.a -lm
//#cgo android,arm64 LDFLAGS: ${SRCDIR}/libs/librnnoise-android-aarch64.a -lm
//#cgo linux,amd64 LDFLAGS: ${SRCDIR}/libs/librnnoise-linux-amd64.a -lm
//#cgo darwin,arm64 LDFLAGS: ${SRCDIR}/libs/librnnoise-darwin-arm64.a
//#cgo windows,amd64 LDFLAGS: ${SRCDIR}/libs/librnnoise-windows-x64.a
import "C"
