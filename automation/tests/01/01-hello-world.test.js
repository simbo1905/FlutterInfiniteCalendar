describe('Demo 01 - App Initialization', function() {
    this.timeout(120000);
    
    it('should load demo data and display meal count', async function() {
        console.log(`[${new Date().toISOString()}] [Test] Starting initialization test...`);
        
        console.log(`[${new Date().toISOString()}] [Test] Waiting for demo data to load (12 meals)...`);
        
        const startTime = Date.now();
        const timeout = 45000;
        let foundInitial = false;
        let foundLoaded = false;
        
        while (Date.now() - startTime < timeout) {
            try {
                const tree = await browser.execute('flutter: renderTree', {});
                const treeString = JSON.stringify(tree);
                
                if (treeString.includes('No Planned Meals') && !foundInitial) {
                    console.log(`[${new Date().toISOString()}] [Test] ✓ Initial state confirmed: No Planned Meals`);
                    foundInitial = true;
                }
                
                if (treeString.includes('Planned Meals: 12')) {
                    foundLoaded = true;
                    console.log(`[${new Date().toISOString()}] [Test] ✓ Demo data loaded: Planned Meals: 12`);
                    break;
                }
                
                await new Promise(resolve => setTimeout(resolve, 500));
            } catch (error) {
                console.log(`[${new Date().toISOString()}] [Test] Error checking render tree:`, error.message);
                await new Promise(resolve => setTimeout(resolve, 500));
            }
        }
        
        if (!foundLoaded) {
            throw new Error('Planned Meals: 12 not found within timeout');
        }
        
        console.log(`[${new Date().toISOString()}] [Test] ✓ App initialization test PASSED`);
    });
});
