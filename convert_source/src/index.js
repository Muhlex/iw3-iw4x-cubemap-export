const fsp = require('fs/promises')
const { readdir, readFile, writeFile } = fsp
const sharp = require('sharp')

const EXPORT_FOLDER = '../_result'
const IN_DIMENSIONS = 256 // cubemap face size on the screen captures
const OUT_DIMENSIONS = 64 // output face size

function chunk(array, size) {
	const sizeInt = parseInt(size)
	if (sizeInt === 0) throw new Error("Cannot chunk into chunks of 0 length.")

	const result = []
	for (let i = 0; i < array.length; i += sizeInt) {
		result.push(array.slice(i, i + sizeInt))
	}
	return result
}

function RGBtoBGRA(data) {
	const pixelsRGB = chunk(data, 3)
	const pixels = pixelsRGB.map(RGB => {
		return Buffer.from([RGB[2], RGB[1], RGB[0], 0xFF])
	})
	return Buffer.concat(pixels)
}

(async () => {
	const filenames = await readdir(EXPORT_FOLDER)
	const cubemapsFilenames = chunk(filenames, 6)
	const cubemaps = await Promise.all(cubemapsFilenames.map(async faceFilenames => {
		return await Promise.all(faceFilenames.map(async (faceFilename, faceIndex) => {
			const faceFile = await readFile(`${EXPORT_FOLDER}/${faceFilename}`)
			const faceRaw = await sharp(faceFile)
				.extract({ left: 0, top: 0, width: IN_DIMENSIONS, height: IN_DIMENSIONS })
				.resize({ kernel: 'cubic', width: OUT_DIMENSIONS, height: OUT_DIMENSIONS })
				.rotate({ 0: 90, 1: -90, 2: 180, 3: 0, 4: 90, 5: 90 }[faceIndex])
				.flop()
				.raw()
				.toBuffer()
			const result = { full: RGBtoBGRA(faceRaw), mips: new Map() }
			// generate mipmaps
			for (let i = OUT_DIMENSIONS / 2; i >= 1; i /= 2) {
				const mipRaw = await sharp(faceRaw, { raw: { width: OUT_DIMENSIONS, height: OUT_DIMENSIONS, channels: 3 } })
					.resize({ kernel: 'cubic', width: i, height: i })
					.raw()
					.toBuffer()
				result.mips.set(i, RGBtoBGRA(mipRaw))
			}
			return result
		}))
	}))

	const headerData = await readFile('./header')
	const iw4xImages = cubemaps.map(cubemap => {
		const facesData = cubemap.map(face => {
			return Buffer.concat([face.full, ...face.mips.values()])
		})
		return Buffer.concat([headerData, ...facesData])
	})

	iw4xImages.forEach((imageData, i) => {
		writeFile(`${EXPORT_FOLDER}/reflection_probe${i + 1}.iw4xImage`, imageData)
	})
})()
