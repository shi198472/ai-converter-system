#!/usr/bin/env python3
"""
Cloudflare Pages 自动化部署脚本
自动完成 Token 验证、项目创建和部署
"""

import os
import sys
import json
import subprocess
import requests
from pathlib import Path

# 颜色输出
class Colors:
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    BLUE = '\033[94m'
    END = '\033[0m'
    BOLD = '\033[1m'

def print_success(msg):
    print(f"{Colors.GREEN}✅ {msg}{Colors.END}")

def print_error(msg):
    print(f"{Colors.RED}❌ {msg}{Colors.END}")

def print_info(msg):
    print(f"{Colors.BLUE}ℹ️  {msg}{Colors.END}")

def print_warning(msg):
    print(f"{Colors.YELLOW}⚠️  {msg}{Colors.END}")

def load_env():
    """加载环境变量"""
    env_file = Path(".env.cloudflare")
    if not env_file.exists():
        print_error(f"环境变量文件 {env_file} 不存在")
        print_info("请创建 .env.cloudflare 文件，包含:")
        print_info("CLOUDFLARE_API_TOKEN=你的token")
        print_info("CLOUDFLARE_ACCOUNT_ID=你的account_id")
        sys.exit(1)
    
    env_vars = {}
    with open(env_file) as f:
        for line in f:
            line = line.strip()
            if line and not line.startswith('#'):
                if '=' in line:
                    key, value = line.split('=', 1)
                    env_vars[key.strip()] = value.strip()
    
    required = ['CLOUDFLARE_API_TOKEN', 'CLOUDFLARE_ACCOUNT_ID']
    for var in required:
        if var not in env_vars:
            print_error(f"缺少必要的环境变量: {var}")
            sys.exit(1)
    
    return env_vars

def test_cloudflare_api(token, account_id):
    """测试 Cloudflare API 连接"""
    print_info("测试 Cloudflare API 连接...")
    
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    }
    
    # 测试1: 验证 Token
    try:
        response = requests.get(
            "https://api.cloudflare.com/client/v4/user/tokens/verify",
            headers=headers,
            timeout=10
        )
        
        if response.status_code == 200:
            data = response.json()
            if data.get("success"):
                print_success("Cloudflare API Token 验证成功")
                print_info(f"Token ID: {data['result']['id']}")
                print_info(f"状态: {data['result']['status']}")
                print_info(f"有效期至: {data['result']['expires_on']}")
                return True
            else:
                print_error(f"Token 验证失败: {data.get('errors', [{}])[0].get('message', '未知错误')}")
        else:
            print_error(f"API 请求失败: HTTP {response.status_code}")
            
    except requests.exceptions.RequestException as e:
        print_error(f"网络连接错误: {e}")
    
    return False

def check_wrangler():
    """检查 Wrangler CLI 是否安装"""
    print_info("检查 Wrangler CLI...")
    try:
        result = subprocess.run(
            ["wrangler", "--version"],
            capture_output=True,
            text=True,
            timeout=5
        )
        if result.returncode == 0:
            version = result.stdout.strip()
            print_success(f"Wrangler 已安装: {version}")
            return True
        else:
            print_error("Wrangler 未正确安装")
    except FileNotFoundError:
        print_error("Wrangler CLI 未安装")
    
    print_info("正在安装 Wrangler CLI...")
    try:
        subprocess.run(
            ["npm", "install", "-g", "wrangler"],
            check=True,
            capture_output=True,
            text=True
        )
        print_success("Wrangler CLI 安装成功")
        return True
    except subprocess.CalledProcessError as e:
        print_error(f"安装 Wrangler 失败: {e}")
        return False

def login_to_cloudflare(token):
    """登录到 Cloudflare"""
    print_info("登录到 Cloudflare...")
    
    # 设置环境变量让 Wrangler 使用我们的 Token
    env = os.environ.copy()
    env["CLOUDFLARE_API_TOKEN"] = token
    
    try:
        # 使用 --api-key 参数登录
        result = subprocess.run(
            ["wrangler", "login", "--api-key"],
            input=f"{token}\n",
            text=True,
            capture_output=True,
            env=env,
            timeout=30
        )
        
        if result.returncode == 0:
            print_success("Cloudflare 登录成功")
            return True
        else:
            print_error(f"登录失败: {result.stderr}")
            return False
            
    except subprocess.TimeoutExpired:
        print_error("登录超时")
        return False
    except Exception as e:
        print_error(f"登录过程出错: {e}")
        return False

def create_pages_project(project_name, account_id):
    """创建 Cloudflare Pages 项目"""
    print_info(f"创建 Cloudflare Pages 项目: {project_name}")
    
    try:
        result = subprocess.run(
            ["wrangler", "pages", "project", "create", project_name,
             "--production-branch", "main"],
            capture_output=True,
            text=True,
            timeout=30
        )
        
        if result.returncode == 0:
            print_success(f"项目 '{project_name}' 创建成功")
            return True
        else:
            # 检查项目是否已存在
            if "already exists" in result.stderr.lower():
                print_warning(f"项目 '{project_name}' 已存在，跳过创建")
                return True
            else:
                print_error(f"创建项目失败: {result.stderr}")
                return False
                
    except subprocess.TimeoutExpired:
        print_error("创建项目超时")
        return False

def build_frontend():
    """构建前端项目"""
    print_info("构建前端项目...")
    
    frontend_dir = Path("frontend")
    if not frontend_dir.exists():
        print_error("前端目录 'frontend' 不存在")
        return False
    
    os.chdir(frontend_dir)
    
    try:
        # 安装依赖
        print_info("安装依赖...")
        install_result = subprocess.run(
            ["npm", "ci"],
            capture_output=True,
            text=True,
            timeout=300
        )
        
        if install_result.returncode != 0:
            print_error(f"安装依赖失败: {install_result.stderr}")
            os.chdir("..")
            return False
        
        print_success("依赖安装成功")
        
        # 构建项目
        print_info("构建项目...")
        build_result = subprocess.run(
            ["npm", "run", "build"],
            capture_output=True,
            text=True,
            timeout=300,
            env={**os.environ, "CI": "false"}
        )
        
        if build_result.returncode != 0:
            print_error(f"构建失败: {build_result.stderr}")
            os.chdir("..")
            return False
        
        print_success("项目构建成功")
        
        # 创建必要的部署文件
        dist_dir = Path("dist")
        if dist_dir.exists():
            os.chdir(dist_dir)
            
            # 创建 _redirects 文件
            with open("_redirects", "w") as f:
                f.write("/* /index.html 200\n")
            
            # 创建 _headers 文件
            with open("_headers", "w") as f:
                f.write("""/*
  X-Frame-Options: DENY
  X-Content-Type-Options: nosniff
  Referrer-Policy: strict-origin-when-cross-origin
  Permissions-Policy: camera=(), microphone=(), geolocation=()
  Cache-Control: public, max-age=3600
""")
            
            print_success("部署文件创建成功")
            
            # 返回项目根目录
            os.chdir("../..")
            return True
        else:
            print_error("构建输出目录 'dist' 不存在")
            os.chdir("..")
            return False
            
    except subprocess.TimeoutExpired:
        print_error("构建过程超时")
        os.chdir("..")
        return False
    except Exception as e:
        print_error(f"构建过程出错: {e}")
        os.chdir("..")
        return False

def deploy_to_pages(project_name):
    """部署到 Cloudflare Pages"""
    print_info(f"部署到 Cloudflare Pages: {project_name}")
    
    deploy_dir = "frontend/dist"
    if not Path(deploy_dir).exists():
        print_error(f"部署目录 '{deploy_dir}' 不存在")
        return False
    
    try:
        result = subprocess.run(
            ["wrangler", "pages", "deploy", deploy_dir,
             "--project-name", project_name,
             "--branch", "main"],
            capture_output=True,
            text=True,
            timeout=300
        )
        
        if result.returncode == 0:
            # 提取部署 URL
            output = result.stdout
            for line in output.split('\n'):
                if '.pages.dev' in line:
                    url = line.strip()
                    print_success(f"部署成功！")
                    print_info(f"访问地址: {Colors.BOLD}{url}{Colors.END}")
                    return True
            
            print_success("部署成功！")
            print_info("请在 Cloudflare Dashboard 查看部署详情")
            return True
        else:
            print_error(f"部署失败: {result.stderr}")
            return False
            
    except subprocess.TimeoutExpired:
        print_error("部署超时")
        return False

def main():
    """主函数"""
    print(f"{Colors.BOLD}{Colors.BLUE}=== Cloudflare Pages 自动化部署 ==={Colors.END}")
    
    # 加载环境变量
    env = load_env()
    token = env['CLOUDFLARE_API_TOKEN']
    account_id = env['CLOUDFLARE_ACCOUNT_ID']
    project_name = env.get('PROJECT_NAME', 'ai-converter-system')
    
    print_info(f"项目: {project_name}")
    print_info(f"账户 ID: {account_id}")
    
    # 测试 API 连接
    if not test_cloudflare_api(token, account_id):
        print_error("API 连接测试失败，请检查 Token 和网络连接")
        sys.exit(1)
    
    # 检查并安装 Wrangler
    if not check_wrangler():
        print_error("Wrangler CLI 检查失败")
        sys.exit(1)
    
    # 登录到 Cloudflare
    if not login_to_cloudflare(token):
        print_error("Cloudflare 登录失败")
        sys.exit(1)
    
    # 创建 Pages 项目
    if not create_pages_project(project_name, account_id):
        print_error("创建项目失败")
        sys.exit(1)
    
    # 构建前端
    if not build_frontend():
        print_error("前端构建失败")
        sys.exit(1)
    
    # 部署到 Pages
    if not deploy_to_pages(project_name):
        print_error("部署失败")
        sys.exit(1)
    
    print(f"{Colors.BOLD}{Colors.GREEN}=== 部署完成！ ==={Colors.END}")
    print_info("下一步:")
    print_info("1. 访问 Cloudflare Dashboard 查看部署状态")
    print_info("2. 配置自定义域名（可选）")
    print_info("3. 测试应用功能")
    print_info("4. 设置环境变量（如后端 API 地址）")

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\n❌ 部署被用户中断")
        sys.exit(1)
    except Exception as e:
        print_error(f"部署过程中出现未预期错误: {e}")
        sys.exit(1)