from flask import Flask, request, jsonify
import tensorflow as tf
from PIL import Image, ImageEnhance
import numpy as np
import base64
import io

app = Flask(__name__)

model = tf.keras.models.load_model('/Users/ssdosaofc/Desktop/XXXML/SIH/api/generator.h5', compile=True)
model.compile(optimizer=tf.keras.optimizers.Adam(learning_rate=1e-4), loss='mae')

def preprocess_image(image):
    image = image.resize((256, 256))
    image = (np.array(image) / 127.5) - 1.0
    image = np.expand_dims(image, axis=0)
    return image

def add_sharpness_gradient(image, sharpness_start=0.5, sharpness_end=2.0):
    image_np = np.array(image)
    height = image_np.shape[0]
    gradient = np.linspace(sharpness_start, sharpness_end, height)
    result = Image.new("RGB", image.size)
    for y in range(height):
        row = image.crop((0, y, image.width, y + 1))
        enhancer = ImageEnhance.Sharpness(row)
        enhanced_row = enhancer.enhance(gradient[y])
        result.paste(enhanced_row, (0, y))
    return result

@app.route('/predict', methods=['POST'])
def predict():
    try:
        data = request.json
        if 'image' not in data:
            return jsonify({"error": "No image data provided"}), 400

        image_data = base64.b64decode(data['image'])
        image = Image.open(io.BytesIO(image_data))
        
        image_with_gradient = add_sharpness_gradient(image)
        
        processed_image = preprocess_image(image_with_gradient)
        
        prediction = model.predict(processed_image)
        result_array = np.squeeze(prediction)
        result_array = ((result_array + 1.0) * 127.5).astype(np.uint8)
        
        result_image = Image.fromarray(result_array)
        
        buffered = io.BytesIO()
        result_image.save(buffered, format="JPEG")
        img_str = base64.b64encode(buffered.getvalue()).decode("utf-8")
        
        return jsonify({"result": img_str})

    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001, debug=True)
