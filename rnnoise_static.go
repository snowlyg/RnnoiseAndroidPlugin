//go:build !dynamic
// +build !dynamic

package rnnoise_android

//#cgo CFLAGS: -I${SRCDIR}/include
//#cgo CXXFLAGS: -I${SRCDIR}/include
//#cgo android,arm LDFLAGS: ${SRCDIR}/lib/librnnoise-android-armv7a.a -lm
//#cgo android,arm64 LDFLAGS: ${SRCDIR}/lib/librnnoise-android-aarch64.a -lm
import "C"
