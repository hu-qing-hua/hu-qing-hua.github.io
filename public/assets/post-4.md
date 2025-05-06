---
title: "leetcode weekly contest record"
date: 2025-04-23T02:01:58+05:30
description: "记录一下在有限时间内解题的表现"
tags: [Problem Record]
---
# leetcode weekly contest 445 
这次没有通过的两道题，一道需要计算组合数的题，一道很久没用过的数位dp方向的题
## 3518 Smallest Palindromic Rearrangement ii
```cpp
class Solution {
public:
 string smallestPalindrome(string s, int k) {
    std::string result;
    char jishu=' ';
  auto compare = [](const char &a, const char &b) {
    return a < b;
  }; // map 按照字母排序
  std::map<char, int, decltype(compare)> map(compare);
  for (const auto &c : s) {
    map[c]++;
  }
  for (auto &pair : map) {
    if (pair.second % 2 == 1) {
      jishu = pair.first; // 回文串的性质决定只可能存在一组有奇数个相同字符
    }
    pair.second /= 2;
  }
  // 需要处理的左半边总长 按照题意n<=5000
  int n = static_cast<int>(s.size()) / 2;
  // plan1 直接计算排列数 n!/ (n1!*n2!*n3!......)
  // ni是各重复字符的出现次数 但是n!显然太大了

  // plan2  eg：组合数的累积乘法
  long maxk = 1000001;
  auto Cal = [maxk](int n, int k) {
    if (k > n || k < 0) {
      return 0L;
    }
    if (k == 0) {
      return 1L;
    }
    k = k < n - k ? k : n - k;
    long result = 1;
    for (int i = 1; i <= k; i++) {
      //result *= (n - i + 1) / i;//先除后乘了，3/2的时候约成1了，C(4,2)变成4*（3/2)=4了
      result=result*(n-i+1)/i;
      if (result > maxk) {
        return maxk;
      }
    }
    return result;
  };

  auto Combine = [&map,Cal, maxk,&k](int lastn, char character) -> bool {
    map[character] -= 1;
    long num = 1;
    for (const auto pair : map) {
      num *= Cal(lastn, pair.second);
      lastn -= pair.second;
      if (num > maxk) {
        return true;
      }
    }
    if (num >= k) {
      return true;
    }
    k-=num; //虽然以character开头的所有可能排列数小于k，之后继续查找肯定是在以比character大的字母开头找，算是排除了一部分比第k个回文最小字符串小的字符串可能
    map[character] += 1;
    return false;
  };

  for (int i = 0; i < n; i++) {
    for (auto &pair : map) {
      if (Combine(n - i - 1, pair.first)) {
        result+=pair.first;
        break;
      }
    }
    if(result.size()!=i+1){
        return "";
    }
  }
  std::string restring(result.rbegin(),result.rend());
  if(jishu==' '){
    result+=restring;
  }
  else{
    result+=jishu+restring;
  }
  return result;
}   
};
```