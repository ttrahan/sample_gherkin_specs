Feature: Create new connection to a MySQL database table
  As a user, I need to be able to connect to data in a MySQL database because my organization stores data I need for my analysis in MySQL.

  Background:
    Given a MySQL database
      And it is accessible to the user

  Scenario: Initiate 'connect to new data source' from Tableau Start Page via Top Choices list
    Given user is on the Tableau Start Page
    When user views the Left Pane
    Then user should see a list of top connection options titled 'Connect' and grouped by the categories 'To a file', 'To a server', and 'Saved data sources'
      And MySQL should be listed as the third item in the 'To a server' section
      And user should be able to initiate a new MySQL connection by clicking this link

  Scenario: Initiate 'connect to new data source' from Tableau Start Page via Search bar
    Given user is on the Tableau Start Page
    When user views the Main Body (to right of Left Pane)
    Then user should see a Search text box with a full list of connection options below it
      And when user begins typing in search string the list should dynamically filter to match their input
      And the search string entered should be able to appear anywhere within the list of searched connection names (e.g. 'sql' should return 'SQL Server' and 'MySQL')
      And the search should be case insensitive
      And user should be able to initiate a new MySQL connection by clicking a link in the filtered or unfiltered list

  Scenario: Initiate 'connect to new data source' from Tableau Workspace toolbar
    Given user is on the Tableau Workspace
      And user has 'Show toolbar' selected in Window menu
    When user clicks 'New data source' toolbar button or executes Command-D keyboard shortcut
    Then display a 'connect to new data source' modal window
      And user should see a list of top connection options in the Left Pane of the modal window titled 'Connect' and grouped by the categories 'To a file', 'To a server', and 'Saved data sources'
      And MySQL should be listed as the third item in the 'To a server' section
      And user should be able to initiate a new MySQL connection by clicking this link in the Left Pane
      And user should see a Search text box with a full list of connection options below it in the Main Body of the modal window (to right of Left Pane)
      And when user begins typing in search string the list should dynamically filter to match their input
      And the search string entered should be able to appear anywhere within the list of searched connection names (e.g. 'sql' should return 'SQL Server' and 'MySQL')
      And the search should be case insensitive
      And user should be able to initiate a new MySQL connection by clicking a link in the filtered or unfiltered list

  Scenario: Prompt user for MySQL connection details
    When user selects to create a new MySQL connection
    Then a modal window should appear
      And user is prompted to enter the following required items
      """
      Server: (name or URL)
      Port (default to MySQL default port of 3306)
      Username:
      Password:
      """
      And user is given the option to 'Require SSL' communication for the connection
      And user is given a button to submit the entries and proceed
      And user is given a button to cancel and return to Tableau Workspace

  Scenario: Prompt user to install required MySQL drivers if not installed
    Given user does not have the required Tableau Drivers for MySQL installed
    When user submits the MySQL connection details
    Then notify the user via a dialog box with error message 'The drivers required to connect to the MySQL Database data source {server name or URL} are not installed.'
      And provide link to 'Download and install the drivers' from the Tableau Drivers support page 'https://www.tableau.com/en-us/support/drivers?edition=pro&lang=en-us&platform=mac&cpu=64&version=9.3&__full-version=9300.16.0726.1843#mysql)'
      And launch browser and take user to that page when link is clicked
      And display detailed error message indicating that the required driver could not be found

  Scenario: Prompt user to verify connection if unable to connect to server
    Given user has the required Tableau Drivers for MySQL installed
      And user has submitted the MySQL connection details
    When unable to connect to the specified MySQL server
    Then notify the user via a dialog box with error message 'An error occurred while communicating with the MySQL Database data source {server name or URL}. Unable to connect to the server. Check that the server is running and that you have access privileges to the requested database.'
      And provide 'Ok' button to return to modal window for entering MySQL connection details where user can correct server information or perform other actions, like starting the MySQL server
      And provide button to 'Show Details'
      And if 'Show Details' is clicked expand dialog box to also display the detailed error message from the console

  Scenario: Prompt user to correct username or password
    Given user has the required Tableau Drivers for MySQL installed
      And user has submitted the MySQL connection details
      And Tableau Desktop is able to connect to the provided MySQL server
    When unable to access the specified MySQL server
    Then notify the user via a dialog box with error message 'An error occurred while communicating with the MySQL Database data source {server name or URL}. Invalid username or password.'
      And provide 'Ok' button to return to modal window where user can correct the provided username or passord
      And provide button to 'Show Details'
      And if 'Show Details' is clicked expand dialog box to also display the detailed error message from the console

  Scenario: Display Data Source Page
    Given user has the required Tableau Drivers for MySQL installed
      And user has submitted the MySQL connection details
      And Tableau Desktop is able to connect to the provided MySQL server
    When Tableau Desktop successfully authenticates with the provided user credentials to the MySQL server instance
    Then display a Data Source Page where users will configure the data to add to their workspace consisting of a Left Pane, a Canvas in upper Main Body, and a Data view in lower Main Body
      And in the Left Pane display a section called 'Server' and display the server name connected to
      And in the Left Pane display a section called 'Database' and display the available Databases that the user has access to in a dropdown menu within that section
      And prompt the user to select a database from the dropdown by displaying 'Select Database' as the default value in the dropdown

  Scenario: Display available database tables
    Given user has successfully connected and authenticated to the MySQL server
      And is on Data Source Page
    When the user selects a database from the list of available databases
    Then display the available tables from that database that the user has permissions to access in a sorted list (A->Z) in the Left Pane in a section titled 'Table'
      And provide a Search text box to allow user to filter the list of available tables by typing in a search string
      And provide an option to provide a Custom SQL script to pull data

  Scenario: Add data source table to Canvas
    Given user has selected a database from the list of available databases
    When the user clicks and drags a table from the Table list in the Left Pane into the Canvas
    Then add the table to the Canvas in the upper Main Body
      And display the table name within a rounded corner rectangle
      And provide options via radio buttons at top of Canvas to create a live connection to the data or a data extract
      And if data extract option is chosen, provide option to filter the data extracted (default = all data)
      And display all of the columns from that table in the Data view in the lower Main Body
      And display the columns in Grid view by default with each column displayed across the top in order they exist in the database
      And for each column, display a symbol representing the column's data type, the table name the column came from, and the column name
      And set the data type to be the data type retrieved from the database
      And provide a dropdown menu next to the data type icon that allows the user to manually change the data type
      And provide a dropdown menu for each column header that allows the user to perform the following:
        """
        | menu option | purpose                                       |
        | ----------------------------------------------------------- |
        | Rename       | rename the column                            |
        | Reset name   | reset the column name back to the original value pulled from the database |
        | Copy         | copy the field and its data to the clipboard |
        | Hide         | hide the column                              |
        | Create calculated field | create calculated field based on the field |
        | Create group | create groups for column's data values       |
        | Create bins  | create bins for column's data values         |
        | Describe     | add text description to column               |
        """
      And display buttons called 'Update Now' and 'Automatically Update' to populate the Data View with actual data from the data source
      And provide a dropdown menu at top of Data View to allow user to change the sort order of the columns, providing the following options:
        """
        Data source order (default)
        A to Z ascending
        Z to A descending
        A to Z ascending per table (e.g. columns grouped by table)
        Z to A descending per table
        """
      And provide select box called 'Show aliases' to toggle between showing and hiding aliases (default = hide)
      And provide select box called 'Show hidden fields' to toggle between showing and hiding hidden fields (default = hide)
      And provide text box where user can specify how many data records to return to the Data View upon update (default = 1000)
