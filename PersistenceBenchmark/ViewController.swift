import UIKit

/**
 * BenchmarkViewController - Performance Testing User Interface
 * 
 * This view controller provides the user interface for executing and displaying
 * performance benchmarks between Core Data, SQLite, and Realm implementations.
 * It manages the benchmark execution flow and presents results in a clear format.
 * 
 * Key Features:
 * - Single-tap benchmark execution
 * - Real-time progress indication
 * - Comprehensive results display
 * - Three-way performance comparison
 * - User-friendly interface design
 * 
 * User Experience:
 * - Simple "Run Benchmark" button
 * - Results displayed in organized table
 * - Performance metrics with clear formatting
 * - Winner identification for each operation
 */
final class BenchmarkViewController: UIViewController {
    
    // MARK: - UI Components
    
    /// Table view for displaying benchmark results
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    /// Button to initiate benchmark execution
    private let runButton = UIButton(type: .system)
    
    // MARK: - Data Properties
    
    /// Array of benchmark results to display
    private var benchmarkResults: [BenchmarkResult] = []
    
    /// Benchmark manager instance for executing tests
    private let benchmarkManager = BenchmarkManager()
    
    // MARK: - Lifecycle Methods
    
    /**
     * Configure view controller after loading
     * 
     * This method sets up the user interface components and configures
     * the initial state of the view controller. It establishes the
     * table view and button layout for the benchmark interface.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Persistence Benchmark"
        view.backgroundColor = .systemBackground
        
        setupTableView()
        setupButton()
    }
    
    // MARK: - UI Setup Methods
    
    /**
     * Configure and layout the results table view
     * 
     * This method sets up the table view for displaying benchmark results
     * with proper constraints and cell registration. The table view uses
     * a grouped style for better visual organization of results.
     */
    private func setupTableView() {
        tableView.dataSource = self
        tableView.register(ResultCell.self, forCellReuseIdentifier: ResultCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    /**
     * Configure and layout the benchmark execution button
     * 
     * This method sets up the primary action button for initiating
     * benchmark execution. The button is positioned at the top of the
     * interface for easy access and clear visual hierarchy.
     */
    private func setupButton() {
        runButton.setTitle("Run Benchmark", for: .normal)
        runButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        runButton.backgroundColor = .systemBlue
        runButton.setTitleColor(.white, for: .normal)
        runButton.layer.cornerRadius = 8
        runButton.translatesAutoresizingMaskIntoConstraints = false
        runButton.addTarget(self, action: #selector(runBenchmark), for: .touchUpInside)
        view.addSubview(runButton)
        
        NSLayoutConstraint.activate([
            runButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            runButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            runButton.widthAnchor.constraint(equalToConstant: 200),
            runButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    // MARK: - Benchmark Execution
    
    /**
     * Execute comprehensive benchmark suite
     * 
     * This method initiates the complete benchmark testing process,
     * including both insert and update operations across all three
     * persistence implementations. It provides user feedback during
     * execution and updates the interface with results.
     * 
     * Execution Flow:
     * - Disable button and show progress indication
     * - Execute benchmarks on background queue
     * - Update UI on main queue with results
     * - Re-enable button for subsequent runs
     * 
     * Performance Considerations:
     * - Background execution prevents UI blocking
     * - Progress indication maintains user engagement
     * - Results update provides immediate feedback
     */
    @objc private func runBenchmark() {
        runButton.isEnabled = false
        runButton.setTitle("Running...", for: .normal)
        runButton.backgroundColor = .systemGray
        
        DispatchQueue.global(qos: .userInitiated).async {
            let results = self.benchmarkManager.runAllBenchmarks()
            DispatchQueue.main.async {
                self.benchmarkResults = results
                self.tableView.reloadData()
                self.runButton.isEnabled = true
                self.runButton.setTitle("Run Benchmark", for: .normal)
                self.runButton.backgroundColor = .systemBlue
            }
        }
    }
}

// MARK: - Table View Data Source

/**
 * Table view data source implementation for benchmark results
 * 
 * This extension provides the data source methods for displaying
 * benchmark results in the table view. It handles result formatting
 * and cell configuration for optimal user experience.
 */
extension BenchmarkViewController: UITableViewDataSource {
    
    /**
     * Return number of sections in table view
     * 
     * @param tableView The table view requesting the information
     * @return Number of sections (always 1 for this implementation)
     */
    func numberOfSections(in tableView: UITableView) -> Int { 
        return 1 
    }
    
    /**
     * Return number of rows in the specified section
     * 
     * @param tableView The table view requesting the information
     * @param section The section index
     * @return Number of benchmark results
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 
        return benchmarkResults.count 
    }
    
    /**
     * Configure and return a cell for the specified index path
     * 
     * This method creates and configures a ResultCell for displaying
     * benchmark results. It passes the benchmark result data to the
     * cell for proper formatting and display.
     * 
     * @param tableView The table view requesting the cell
     * @param indexPath The index path for the cell
     * @return Configured ResultCell instance
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ResultCell.identifier, for: indexPath) as! ResultCell
        let result = benchmarkResults[indexPath.row]
        cell.configure(with: result)
        return cell
    }
}
