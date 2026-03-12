# Test Command

Write tests for a specific file or feature.

## Input
$ARGUMENTS

Provide a file path or feature name to test.

## Instructions

1. **Analyze the file/feature**
   - Read and understand what needs testing
   - Identify public APIs, functions, and behaviors
   - Note dependencies that may need mocking

2. **Identify test cases**:

   ### Happy Path
   - Normal expected usage
   - Valid inputs produce correct outputs

   ### Edge Cases
   - Boundary conditions
   - Empty inputs, max values
   - Unusual but valid scenarios

   ### Error States
   - Invalid inputs
   - Network failures
   - Missing data

3. **Write tests incrementally**
   - Start with happy path tests
   - Add edge cases
   - Add error handling tests

4. **Test runner**: [TBD - will be configured based on project setup]

5. **Ensure tests are**:
   - Isolated and independent
   - Clear in what they're testing
   - Fast to execute
