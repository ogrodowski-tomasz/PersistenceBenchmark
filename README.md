# PersistenceBenchmark

A comprehensive iOS performance benchmarking application that compares four major persistence solutions: **Core Data**, **SQLite**, **Realm**, and **SwiftData**. This project provides detailed performance metrics and insights to help developers choose the optimal persistence solution for their iOS applications.

## 🎯 Project Overview

PersistenceBenchmark is designed to measure and compare the performance characteristics of different iOS persistence frameworks across various database operations. It provides real-world performance data to help developers make informed decisions about which persistence solution best fits their application's needs.

## 🏗️ Architecture

The project follows a clean, modular architecture with the following key components:

### Core Components

- **`DatabaseManager` Protocol**: Defines a common interface for all persistence implementations
- **`BenchmarkManager`**: Orchestrates performance tests and statistical analysis
- **`BenchmarkResult`**: Holds performance metrics and comparison data
- **`Person` Model**: Simple data structure used for testing across all implementations

### Persistence Implementations

1. **Core Data Manager** ([`CoreDataManager`](https://github.com/ogrodowski-tomasz/PersistenceBenchmark/blob/main/PersistenceBenchmark/CoreData/CoreDataManager.swift))
   - Apple's object graph and persistence framework
   - Uses `NSPersistentContainer` and `NSManagedObjectContext`
   - Implements merge policies and batch operations

2. **SQLite Manager** ([`SQLiteManager`](https://github.com/ogrodowski-tomasz/PersistenceBenchmark/blob/main/PersistenceBenchmark/SQLite/SQLiteManager.swift))
   - Direct SQLite C API implementation
   - Uses prepared statements and transactions
   - Maximum performance with minimal overhead

3. **Realm Manager** ([`RealmManager`](https://github.com/ogrodowski-tomasz/PersistenceBenchmark/blob/main/PersistenceBenchmark/Realm/RealmManager.swift))
   - Modern object-oriented database
   - Zero-copy object access and automatic persistence
   - Thread-safe operations with context management

4. **SwiftData Manager** ([`SwiftDataManager`](https://github.com/ogrodowski-tomasz/PersistenceBenchmark/blob/main/PersistenceBenchmark/SwiftData/SwiftDataManager.swift))
   - Apple's latest Swift-first data framework
   - Type-safe operations with compile-time checks
   - Modern Swift syntax with `@Model` macro

## 📊 Performance Test Results

Based on comprehensive testing with 1,000 records and 10 repetitions per operation:

### Update Operations Performance

| Operation | Core Data | SQLite | Realm | SwiftData | Winner |
|-----------|-----------|--------|-------|-----------|---------|
| **Update Single** | 0.0009s | **0.0001s** | 0.0002s | 0.0144s | 🏆 SQLite |
| **Update Bulk** | 1.9859s | **0.0002s** | 0.0039s | 0.0376s | 🏆 SQLite |
| **Update Conditional** | 1.9813s | **0.0002s** | 0.0041s | 0.0371s | 🏆 SQLite |
| **Update Incremental** | 1.9493s | **0.0005s** | 0.0029s | 0.0386s | 🏆 SQLite |
| **Update Multiple** | 0.0932s | **0.0002s** | 0.0011s | 0.0202s | 🏆 SQLite |

### Key Performance Insights

- **SQLite Dominates**: Consistently fastest across all update operations
- **Realm Shows Strong Performance**: Second-best performance with modern object-oriented approach
- **Core Data Struggles**: Significant overhead in bulk operations (1.9s+ vs 0.0002s for SQLite)
- **SwiftData Needs Optimization**: Currently slowest, likely due to early implementation and overhead

## 🚀 Features

### Comprehensive Benchmarking
- **Insert Operations**: Single vs bulk insertion performance
- **Update Operations**: Various update strategies and patterns
- **Query Performance**: Different search and filtering operations
- **Statistical Analysis**: Multiple repetitions with average calculations

### Detailed Performance Metrics
- **Execution Time**: Precise timing measurements
- **Performance Comparison**: Side-by-side framework comparison
- **Winner Identification**: Automatic fastest implementation detection
- **Improvement Percentages**: Performance gain calculations

## 🛠️ Technical Implementation

### Database Operations Tested

#### Insert Operations
- **Single Insert**: Individual record insertion with transaction overhead
- **Bulk Insert**: Batch insertion for maximum efficiency

#### Update Operations
- **Single Update**: Individual record modification by ID
- **Bulk Update**: Mass data modification across all records
- **Conditional Update**: Query + update operations within age ranges
- **Incremental Update**: Mathematical operations on existing values
- **Multiple Update**: Targeted batch operations on specific records

### Performance Characteristics

#### Core Data
- **Strengths**: Rich object graph, automatic persistence, relationship management
- **Weaknesses**: High overhead in bulk operations, complex setup
- **Best For**: Complex data models with relationships

#### SQLite
- **Strengths**: Maximum performance, direct database access, minimal overhead
- **Weaknesses**: Manual SQL management, no object mapping
- **Best For**: High-performance applications, simple data structures

#### Realm
- **Strengths**: Modern object-oriented approach, zero-copy access, automatic persistence
- **Weaknesses**: Learning curve, specific query syntax
- **Best For**: Modern Swift applications, real-time data

#### SwiftData
- **Strengths**: Type-safe operations, modern Swift syntax, automatic model management
- **Weaknesses**: Early implementation, performance overhead, limited features
- **Best For**: Future-proofing, type safety requirements

## 🔍 Detailed Framework Analysis

### 🍎 **Core Data**

#### ✅ **Pros**
- **Apple Ecosystem Integration**: Native iOS framework with deep system integration
- **Rich Object Graph**: Excellent for complex data models with relationships
- **Automatic Persistence**: Built-in change tracking and undo/redo support
- **CloudKit Integration**: Seamless cloud synchronization with `NSPersistentCloudKitContainer`
- **Mature Framework**: Battle-tested with extensive documentation and community support
- **Relationship Management**: Automatic handling of object relationships and cascading deletes
- **Memory Management**: Automatic faulting and memory optimization for large datasets

#### ❌ **Cons**
- **Performance Overhead**: Significant overhead in bulk operations (1.9s+ vs 0.0002s for SQLite)
- **Complex Setup**: Steep learning curve with complex configuration
- **Memory Usage**: High memory consumption with large datasets
- **Threading Complexity**: Complex context management and thread safety requirements
- **Migration Challenges**: Difficult schema migrations and data model changes

#### 🎯 **When to Use Core Data**
- **Complex Data Models**: Applications with rich object relationships
- **Cloud Synchronization**: Apps requiring iCloud data sync
- **Apple Ecosystem**: iOS-only applications with deep system integration
- **Undo/Redo Support**: Applications requiring complex undo functionality
- **Mature Applications**: Long-term projects where stability is crucial

#### 🚫 **When to Avoid Core Data**
- **High Performance Requirements**: Real-time applications needing maximum speed
- **Simple Data Structures**: Basic CRUD operations without complex relationships
- **Cross-Platform**: Applications targeting multiple platforms
- **Rapid Prototyping**: Quick development cycles where simplicity is key

---

### 🗄️ **SQLite**

#### ✅ **Pros**
- **Maximum Performance**: Consistently fastest across all operations (100x faster than Core Data)
- **Minimal Overhead**: Direct database access with minimal abstraction
- **Cross-Platform**: Works on iOS, Android, and other platforms
- **Mature Technology**: Battle-tested database engine used by major applications
- **Full Control**: Complete control over SQL queries and database operations
- **Lightweight**: Minimal memory footprint and resource usage
- **Standard SQL**: Familiar SQL syntax for database operations

#### ❌ **Cons**
- **Manual SQL Management**: Requires writing and maintaining SQL queries
- **No Object Mapping**: Manual conversion between objects and database records
- **Threading Complexity**: Manual thread safety management
- **No Built-in Relationships**: Manual foreign key management
- **Learning Curve**: Requires SQL knowledge and database design skills
- **No Automatic Persistence**: Manual change tracking and persistence

#### 🎯 **When to Use SQLite**
- **High Performance Requirements**: Real-time applications, games, or data-intensive apps
- **Cross-Platform**: Applications targeting multiple platforms
- **Simple Data Structures**: Basic CRUD operations without complex relationships
- **Custom Queries**: Applications requiring complex SQL queries
- **Resource Constraints**: Memory or storage-limited applications

#### 🚫 **When to Avoid SQLite**
- **Complex Object Models**: Applications with rich object relationships
- **Rapid Development**: Projects requiring quick iteration and prototyping
- **Team with Limited SQL Knowledge**: Teams without database expertise
- **Cloud Synchronization**: Applications requiring automatic cloud sync

---

### 🚀 **Realm**

#### ✅ **Pros**
- **Modern Object-Oriented**: Clean, Swift-first API with modern syntax
- **Zero-Copy Access**: Efficient memory usage with direct object access
- **Automatic Persistence**: Built-in change tracking and automatic persistence
- **Thread Safety**: Automatic thread safety with context management
- **Cross-Platform**: Works on iOS, Android, and other platforms
- **Real-Time Updates**: Live objects that automatically reflect database changes
- **Easy Migration**: Simple schema migration and data model updates
- **Good Performance**: Second-best performance in most operations

#### ❌ **Cons**
- **Vendor Lock-in**: Proprietary database format and API
- **Learning Curve**: Different query syntax and object model
- **File Size**: Larger app bundle due to Realm framework
- **Limited SQL Support**: No standard SQL queries
- **Memory Usage**: Can consume significant memory with large datasets
- **Dependency**: External framework dependency

#### 🎯 **When to Use Realm**
- **Modern Swift Applications**: New projects using modern Swift patterns
- **Real-Time Data**: Applications requiring live data updates
- **Cross-Platform**: Applications targeting multiple platforms
- **Object-Oriented Design**: Applications with rich object models
- **Performance + Simplicity**: Balance between performance and ease of use

#### 🚫 **When to Avoid Realm**
- **Maximum Performance**: Applications requiring absolute maximum speed
- **Standard SQL**: Applications requiring complex SQL queries
- **Minimal Dependencies**: Projects requiring minimal external dependencies
- **Legacy Integration**: Applications with existing Core Data or SQLite code

---

### 🆕 **SwiftData**

#### ✅ **Pros**
- **Type Safety**: Compile-time type checking and safety
- **Modern Swift Syntax**: Latest Swift features and patterns
- **Automatic Model Management**: `@Model` macro for automatic persistence
- **Apple Integration**: Native iOS framework with system integration
- **Future-Proof**: Apple's latest data framework
- **Clean API**: Simple, intuitive API design
- **Automatic Persistence**: Built-in change tracking and persistence

#### ❌ **Cons**
- **Early Implementation**: Still in development with performance issues
- **Limited Features**: Missing advanced features compared to Core Data
- **Performance Overhead**: Currently slowest in most operations
- **iOS 17+ Only**: Limited to newer iOS versions
- **Limited Documentation**: New framework with less community support
- **Migration Challenges**: Limited migration tools and options

#### 🎯 **When to Use SwiftData**
- **Future-Proofing**: New projects planning for long-term Apple support
- **Type Safety**: Applications requiring maximum type safety
- **Modern Swift**: Projects using latest Swift features
- **Simple Data Models**: Basic CRUD operations without complex relationships
- **iOS 17+ Only**: Applications targeting latest iOS versions

#### 🚫 **When to Avoid SwiftData**
- **Performance Critical**: Applications requiring maximum performance
- **Legacy Support**: Applications supporting older iOS versions
- **Complex Relationships**: Applications with complex data models
- **Production Ready**: Applications requiring battle-tested solutions
- **Cross-Platform**: Applications targeting multiple platforms

---

## 🏆 Performance Summary & Recommendations

### **For Maximum Performance**
**Choose SQLite** - Consistently fastest across all operations

### **For Balanced Performance + Modern Features**
**Choose Realm** - Good performance with modern object-oriented approach

### **For Complex Object Models + Apple Integration**
**Choose Core Data** - Rich features despite performance overhead

### **For Future-Proofing + Type Safety**
**Choose SwiftData** - Modern approach with room for optimization

### **Decision Matrix**

| Factor | SQLite | Core Data | Realm | SwiftData |
|--------|--------|-----------|-------|-----------|
| **Performance** | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐ |
| **Ease of Use** | ⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Apple Integration** | ⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐ |
| **Cross-Platform** | ⭐⭐⭐⭐⭐ | ⭐ | ⭐⭐⭐⭐ | ⭐ |
| **Type Safety** | ⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Maturity** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐ |

### **Quick Decision Guide**

**Choose SQLite if:**
- Performance is critical
- You need cross-platform support
- You have SQL expertise
- You're building data-intensive applications

**Choose Core Data if:**
- You need complex object relationships
- You want deep Apple ecosystem integration
- You need cloud synchronization
- You're building iOS-only applications

**Choose Realm if:**
- You want modern object-oriented approach
- You need cross-platform support
- You want good performance with ease of use
- You're building real-time applications

**Choose SwiftData if:**
- You want maximum type safety
- You're targeting iOS 17+ only
- You want future-proofing
- You're building new Swift applications

---

*This benchmark provides valuable insights for iOS developers choosing persistence solutions. The results demonstrate that the optimal choice depends on specific use cases, performance requirements, and development preferences.*
