import requests
import time

def get_proxies():
    api_url = "https://api.coolproxies.com/api.php?list=1&nocountry=CN&l12=1&http=1&ping=100&apikey=75UFWTOWPCPCPEOI"
    
    try:
        # Mengambil data dari API
        response = requests.get(api_url)
        
        # Memastikan request berhasil
        if response.status_code == 200:
            # Mengambil konten dan decode ke string
            proxies = response.text.strip().split('\n')
            
            # Membersihkan data proxy
            cleaned_proxies = [proxy.strip() for proxy in proxies if proxy.strip()]
            
            # Menyimpan ke file (opsional)
            with open('proxies.txt', 'w') as f:
                f.write('\n'.join(cleaned_proxies))
            
            return cleaned_proxies
            
        else:
            print(f"Error: Status code {response.status_code}")
            return None
            
    except Exception as e:
        print(f"Error occurred: {str(e)}")
        return None

# Fungsi untuk mengecek apakah proxy berfungsi
def check_proxy(proxy):
    try:
        test_url = "http://httpbin.org/ip"
        response = requests.get(test_url, 
                              proxies={"http": f"http://{proxy}", "https": f"http://{proxy}"}, 
                              timeout=10)
        return response.status_code == 200
    except:
        return False

# Contoh penggunaan
if __name__ == "__main__":
    # Mengambil daftar proxy
    proxy_list = get_proxies()
    
    if proxy_list:
        print(f"Berhasil mengambil {len(proxy_list)} proxy")
        
        # Menampilkan beberapa proxy pertama
        print("\nContoh proxy yang didapat:")
        for proxy in proxy_list[:5]:
            print(proxy)
            
        # Opsional: Mengecek proxy yang aktif
        print("\nMengecek proxy yang aktif...")
        working_proxies = []
        for proxy in proxy_list:
            if check_proxy(proxy):
                working_proxies.append(proxy)
                print(f"Proxy aktif: {proxy}")
                
        print(f"\nTotal proxy aktif: {len(working_proxies)}")
    else:
        print("Gagal mengambil daftar proxy")
