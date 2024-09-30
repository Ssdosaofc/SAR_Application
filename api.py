from flask import Flask, request, jsonify
import tensorflow as tf
from PIL import Image, ImageEnhance
import numpy as np
import base64
import io

app = Flask(__name__)

# discriminator = tf.keras.models.load_model('/Users/ssdosaofc/Desktop/XXXML/SIH/api/discriminator (1).h5', compile=False)

# def generator_loss(disc_generated_output, target, gen_output):
#     gan_loss = tf.reduce_mean(
#         tf.keras.losses.BinaryCrossentropy(from_logits=True)(
#             tf.ones_like(disc_generated_output), disc_generated_output
#         )
#     )
    
#     l1_loss = tf.reduce_mean(
#         tf.keras.losses.MeanAbsoluteError()(target, gen_output)
#     )

#     total_gen_loss = gan_loss + 100 * l1_loss
#     return total_gen_loss, gan_loss, l1_loss

# def custom_generator_loss_wrapper(disc_model, target):
#     def custom_generator_loss(y_true, y_pred):

#         disc_generated_output = disc_model(y_pred)  
#         total_gen_loss, _, _ = generator_loss(disc_generated_output, y_true, y_pred)
#         return total_gen_loss
#     return custom_generator_loss

# generator = tf.keras.models.load_model('/Users/ssdosaofc/Desktop/XXXML/SIH/api/generator.h5', compile=True)

# generator.compile(
#     optimizer=tf.keras.optimizers.Adam(learning_rate=1e-4),
#     loss=custom_generator_loss_wrapper(discriminator, target=None)  
# )

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



# def preprocess_image(image):
#     image = image.resize((256, 256))
#     image = np.array(image) / 255.0
#     image = np.expand_dims(image, axis=0)
#     return image

# def add_sharpness_gradient(image, sharpness_start=0.5, sharpness_end=2.0):
#     image_np = np.array(image)
#     height = image_np.shape[0]
#     gradient = np.linspace(sharpness_start, sharpness_end, height)
#     result = Image.new("RGB", image.size)
#     for y in range(height):
#         row = image.crop((0, y, image.width, y + 1))
#         enhancer = ImageEnhance.Sharpness(row)
#         enhanced_row = enhancer.enhance(gradient[y])
#         result.paste(enhanced_row, (0, y))
#     return result

# @app.route('/predict', methods=['POST'])
# def predict():
#     if 'image' not in request.files:
#         return jsonify({"error": "No image uploaded"}), 400

#     file = request.files['image']
#     if file:
#         image = Image.open(file)
#         image_with_gradient = add_sharpness_gradient(image)
#         processed_image = preprocess_image(image_with_gradient)
#         prediction = model.predict(processed_image)
#         result_array = np.squeeze(prediction)
#         result_array = (result_array * 255).astype(np.uint8)
#         result_image = Image.fromarray(result_array)
        
#         # Convert result_image to JPEG format
#         buffered = io.BytesIO()
#         result_image.save(buffered, format="JPEG")
#         img_str = base64.b64encode(buffered.getvalue()).decode("utf-8")
        
#         return jsonify({"result": img_str})
#     return jsonify({"error": "Failed to process the image"}), 500

# if __name__ == '__main__':
#     app.run(host='0.0.0.0', port=5001, debug=True)
