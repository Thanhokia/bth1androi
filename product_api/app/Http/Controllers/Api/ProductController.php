<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Product;
use App\Models\Category;
use Illuminate\Support\Facades\Cache;

class ProductController extends Controller
{
    // Lấy toàn bộ danh sách sản phẩm
    public function index()
    {
        $products = Cache::remember('products', 60, function () {
            return Product::with('category')->get();
        });

        return response()->json($products, 200);
    }

    // Lấy chi tiết 1 sản phẩm theo ID
    public function show($id)
    {
        $product = Product::with('category')->find($id);
        if (!$product) {
            return response()->json(['message' => 'Product not found'], 404);
        }
        return response()->json($product, 200);
    }

    // Thêm sản phẩm mới
    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|unique:products,name',
            'description' => 'nullable|string|max:500',
            'price' => 'required|numeric|min:0',
            'category_id' => 'nullable|exists:categories,id',
        ]);

        $product = Product::create($validated);
        // Invalidate products cache
        Cache::forget('products');
        return response()->json($product, 201);
    }

    // Cập nhật sản phẩm
    public function update(Request $request, $id)
    {
        $product = Product::find($id);
        if (!$product) {
            return response()->json(['message' => 'Product not found'], 404);
        }
        $validated = $request->validate([
            'name' => 'required|string|unique:products,name,' . $product->id,
            'description' => 'nullable|string|max:500',
            'price' => 'required|numeric|min:0',
            'category_id' => 'nullable|exists:categories,id',
        ]);

        $product->update($validated);
        // Invalidate products cache
        Cache::forget('products');
        return response()->json($product, 200);
    }

    // Xoá sản phẩm
    public function destroy($id)
    {
        $product = Product::find($id);
        if (!$product) {
            return response()->json(['message' => 'Product not found'], 404);
        }
        $product->delete();
        // Invalidate products cache
        Cache::forget('products');
        return response()->json(['message' => 'Product deleted'], 200);
    }
}
