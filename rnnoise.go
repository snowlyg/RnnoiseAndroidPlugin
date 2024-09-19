package rnnoise_android

// #include <stdlib.h>
// #include "rnnoise.h"
import "C"
import (
	"bytes"
	"encoding/binary"
	"fmt"
	"io"
	"log"
	"os"
	"unsafe"

	"github.com/gen2brain/malgo"
)

var st *C.DenoiseState

const FrameSize = 480

type DenoiseState struct {
	ds *C.DenoiseState
}

func NewDenoiseState() *DenoiseState {
	return &DenoiseState{
		ds: C.rnnoise_create(nil),
	}

}

func (d *DenoiseState) DestoryDenoiseState() {
	if d.ds != nil {
		C.rnnoise_destroy(d.ds)
	}
}

// ProcessByte
func (d *DenoiseState) ProcessByte(sampleCount []byte) []byte {

	piBuffer := bytes.NewReader(sampleCount)

	inputTmp := make([]int16, FrameSize)

	binaryRead(piBuffer, inputTmp)

	inputTmp = d.Process(inputTmp)

	buf := new(bytes.Buffer)
	binaryWrite(buf, inputTmp)

	out := make([]byte, len(sampleCount))
	m, err := buf.Read(out)
	if err == io.EOF {
		println("EOF:", err.Error())
		// break
	}

	return out[:m]

}

// Process
func (d *DenoiseState) Process(inputTmp []int16) []int16 {

	tmp := make([]float32, FrameSize)
	for i := 0; i < FrameSize; i++ {
		tmp[i] = float32(inputTmp[i])
	}

	C.rnnoise_process_frame(d.ds, (*C.float)(unsafe.Pointer(&tmp[0])), (*C.float)(unsafe.Pointer(&tmp[0])))

	for i := 0; i < FrameSize; i++ {
		inputTmp[i] = int16(tmp[i])
	}

	return inputTmp
}

// ProcessFile
func ProcessFile(inputFile string) {
	// Open input and output files
	f1, err := os.Open(inputFile)
	if err != nil {
		log.Fatalf("Failed to open input file: %v", err)
	}
	defer f1.Close()

	ctx, err := malgo.InitContext(nil, malgo.ContextConfig{}, nil)
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
	defer func() {
		_ = ctx.Uninit()
		ctx.Free()
	}()

	sampleCount := make([]byte, FrameSize*2)

	r, w := io.Pipe()
	defer r.Close()
	defer w.Close()

	// // Create a new RNNoise state
	// st := C.rnnoise_create(nil)
	// // Destroy the RNNoise state
	// defer C.rnnoise_destroy(st)
	ds := NewDenoiseState()
	defer ds.DestoryDenoiseState()

	go func() {
		for {
			x, err := f1.Read(sampleCount)
			if err == io.EOF {
				println("EOF:", err.Error())
				break
			}

			out := ds.ProcessByte(sampleCount[:x])

			w.Write(out)
		}
	}()

	deviceConfig := malgo.DefaultDeviceConfig(malgo.Playback)
	deviceConfig.Playback.Format = malgo.FormatS16
	deviceConfig.Playback.Channels = 2
	deviceConfig.SampleRate = 48000
	deviceConfig.Alsa.NoMMap = 1

	// This is the function that's used for sending more data to the device for playback.
	onSamples := func(pOutputSample, pInputSamples []byte, framecount uint32) {
		io.ReadFull(r, pOutputSample)
	}

	deviceCallbacks := malgo.DeviceCallbacks{
		Data: onSamples,
	}
	device, err := malgo.InitDevice(ctx.Context, deviceConfig, deviceCallbacks)
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
	defer device.Uninit()

	err = device.Start()
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}

	fmt.Println("Press Enter to quit...")
	fmt.Scanln()
}

// binaryRead reads a frame of int16 samples from the file.
func binaryRead(f io.Reader, buf []int16) error {
	return binary.Read(f, binary.LittleEndian, buf)
}

// binaryWrite writes a frame of int16 samples to the file.
func binaryWrite(f io.Writer, buf []int16) error {
	return binary.Write(f, binary.LittleEndian, buf)
}
