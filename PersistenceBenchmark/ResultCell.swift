import UIKit

/**
 * ResultCell - Benchmark Results Display Cell
 * 
 * This table view cell displays benchmark results in a clear, organized format.
 * It shows performance metrics for all three persistence implementations
 * and highlights the fastest performer for each operation.
 * 
 * Display Features:
 * - Operation name with clear formatting
 * - Performance metrics for all three systems
 * - Winner identification with color coding
 * - Performance improvement percentage
 * - Clean, readable layout
 * 
 * Visual Design:
 * - Hierarchical information display
 * - Color-coded performance indicators
 * - Consistent formatting across results
 * - Responsive layout for different screen sizes
 */
final class ResultCell: UITableViewCell {
    static let identifier = "ResultCell"
    
    // MARK: - UI Components
    
    /// Label displaying the operation name
    private let operationLabel = UILabel()
    
    /// Label displaying Core Data performance metrics
    private let coreLabel = UILabel()
    
    /// Label displaying SQLite performance metrics
    private let sqliteLabel = UILabel()
    
    /// Label displaying Realm performance metrics
    private let realmLabel = UILabel()
    
    /// Label displaying SwiftData performance metrics
    private let swiftDataLabel = UILabel()
    
    /// Label displaying the fastest implementation
    private let fasterLabel = UILabel()
    
    /// Label displaying performance improvement percentage
    private let improvementLabel = UILabel()
    
    // MARK: - Initialization
    
    /**
     * Initialize the result cell with standard table view cell style
     * 
     * @param style The cell style
     * @param reuseIdentifier The reuse identifier for cell recycling
     */
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - UI Setup
    
    /**
     * Configure and layout all UI components
     * 
     * This method sets up the visual hierarchy and layout constraints
     * for all labels in the result cell. It creates a vertical stack
     * layout for optimal information display and readability.
     */
    private func setupViews() {
        // Configure label fonts and colors
        operationLabel.font = .systemFont(ofSize: 16, weight: .bold)
        operationLabel.textColor = .label
        
        coreLabel.font = .systemFont(ofSize: 14)
        coreLabel.textColor = .systemBlue
        
        sqliteLabel.font = .systemFont(ofSize: 14)
        sqliteLabel.textColor = .systemGreen
        
        realmLabel.font = .systemFont(ofSize: 14)
        realmLabel.textColor = .systemPurple
        
        swiftDataLabel.font = .systemFont(ofSize: 14)
        swiftDataLabel.textColor = .systemOrange
        
        fasterLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        fasterLabel.textColor = .systemGreen
        
        improvementLabel.font = .systemFont(ofSize: 12)
        improvementLabel.textColor = .secondaryLabel
        
        // Create vertical stack layout
        let stack = UIStackView(arrangedSubviews: [
            operationLabel,
            coreLabel,
            sqliteLabel,
            realmLabel,
            swiftDataLabel,
            fasterLabel,
            improvementLabel
        ])
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            stack.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
            stack.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    // MARK: - Data Configuration
    
    /**
     * Configure the cell with benchmark result data
     * 
     * This method populates all labels with the appropriate data from
     * the benchmark result, including performance metrics, winner
     * identification, and improvement percentages.
     * 
     * @param result The benchmark result to display
     */
    func configure(with result: BenchmarkResult) {
        operationLabel.text = result.operation
        coreLabel.text = String(format: "Core Data: %.4fs", result.coreDataAverage)
        sqliteLabel.text = String(format: "SQLite: %.4fs", result.sqliteAverage)
        realmLabel.text = String(format: "Realm: %.4fs", result.realmAverage)
        swiftDataLabel.text = String(format: "SwiftData: %.4fs", result.swiftDataAverage)
        fasterLabel.text = "🏆 Fastest: \(result.fasterMethod)"
        improvementLabel.text = String(format: "Performance improvement: %.1f%%", result.performanceImprovement)
        
        // Highlight the fastest implementation
        highlightFastestImplementation(result)
    }
    
    /**
     * Highlight the fastest implementation with visual emphasis
     * 
     * This method applies visual emphasis to the label representing
     * the fastest implementation, making it easy to identify
     * performance winners at a glance.
     * 
     * @param result The benchmark result containing performance data
     */
    private func highlightFastestImplementation(_ result: BenchmarkResult) {
        // Reset all labels to default appearance
        [coreLabel, sqliteLabel, realmLabel, swiftDataLabel].forEach { label in
            label.font = .systemFont(ofSize: 14)
            label.textColor = label == coreLabel ? .systemBlue : (label == sqliteLabel ? .systemGreen : (label == realmLabel ? .systemPurple : .systemOrange))
        }
        
        // Determine which implementation is fastest
        let times = [
            ("Core Data", result.coreDataAverage, coreLabel),
            ("SQLite", result.sqliteAverage, sqliteLabel),
            ("Realm", result.realmAverage, realmLabel),
            ("SwiftData", result.swiftDataAverage, swiftDataLabel)
        ]
        
        let fastest = times.min { $0.1 < $1.1 }
        
        // Highlight the fastest implementation
        if let fastest = fastest {
            fastest.2.font = .systemFont(ofSize: 14, weight: .bold)
            fastest.2.textColor = .systemOrange
        }
    }
}
