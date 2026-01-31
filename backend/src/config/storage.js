const cloudinary = require('cloudinary').v2;
require('dotenv').config();

cloudinary.config({
    cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
    api_key: process.env.CLOUDINARY_API_KEY,
    api_secret: process.env.CLOUDINARY_API_SECRET
});

class StorageService {
    async upload(filePath) {
        try {
            const result = await cloudinary.uploader.upload(filePath);
            return result.secure_url;
        } catch (error) {
            throw error;
        }
    }
}

module.exports = new StorageService();
