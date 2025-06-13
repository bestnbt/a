from PIL import Image
import os

def resize_image(input_path, output_path, target_resolution=(640, 360)):
    """
    將圖片壓縮到指定的分辨率並儲存到指定路徑。
    
    :param input_path: 輸入圖片的路徑
    :param output_path: 輸出圖片的路徑
    :param target_resolution: 目標分辨率，格式為 (寬度, 高度)，預設為 (640, 360)
    """
    try:
        # 打開圖片
        img = Image.open(input_path)
        
        # 使用高質量縮放（LANCZOS 提供較好的縮放質量）
        img_resized = img.resize(target_resolution, Image.Resampling.LANCZOS)
        
        # 檢查輸出目錄是否存在，不存在則創建
        output_dir = os.path.dirname(output_path)
        if output_dir and not os.path.exists(output_dir):
            os.makedirs(output_dir)
        
        # 保存圖片
        img_resized.save(output_path, quality=95)
        print(f"圖片已成功壓縮並保存到 {output_path}")
        
    except FileNotFoundError:
        print(f"錯誤：找不到輸入圖片 {input_path}")
    except Exception as e:
        print(f"錯誤：處理 {input_path} 時發生錯誤 - {str(e)}")

def batch_resize_images(input_folder, output_folder, target_resolution=(640, 360)):
    """
    批量處理文件夾中的所有圖片，壓縮到指定分辨率並保存。
    
    :param input_folder: 包含圖片的源文件夾路徑
    :param output_folder: 輸出圖片的目標文件夾路徑
    :param target_resolution: 目標分辨率，格式為 (寬度, 高度)，預設為 (640, 360)
    """
    # 支持的圖片格式
    supported_extensions = ('.jpg', '.jpeg', '.png', '.bmp', '.gif')
    
    try:
        # 檢查輸入文件夾是否存在
        if not os.path.exists(input_folder):
            print(f"錯誤：輸入文件夾 {input_folder} 不存在")
            return
        
        # 遍歷輸入文件夾中的所有文件
        for filename in os.listdir(input_folder):
            if filename.lower().endswith(supported_extensions):
                input_path = os.path.join(input_folder, filename)
                output_filename = f"resized_{filename}"
                output_path = os.path.join(output_folder, output_filename)
                
                # 處理單張圖片
                resize_image(input_path, output_path, target_resolution)
                
    except Exception as e:
        print(f"錯誤：批量處理時發生錯誤 - {str(e)}")

def main():
    # 獲取用戶輸入
    input_folder = input("請輸入包含圖片的源文件夾路徑：")
    target_width = int(input("請輸入目標寬度（例如 640）：") or 640)
    target_height = int(input("請輸入目標高度（例如 360）：") or 360)
    output_folder = "/storage/emulated/0/picture"
    
    # 調用批量處理函數
    batch_resize_images(input_folder, output_folder, (target_width, target_height))

if __name__ == "__main__":
    main()