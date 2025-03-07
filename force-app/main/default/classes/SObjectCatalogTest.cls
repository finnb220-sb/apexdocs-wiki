@isTest
private class SObjectCatalogTest {
  static Opportunity opp = new Opportunity(Name = 'Test', StageName = 'Prospecting', CloseDate = Date.Today());

  static testMethod void get() {
    insert opp;

    System.assertEquals(opp.Id, subject().get(opp.Id).Id, 'returns catalog member by ID');
  }

  static testMethod void getBy() {
    insert opp;

    System.assertEquals(opp, subject().getBy('Name', 'Test'), 'maps by field name, caches, then returns catalog member');
  }

  static testMethod void values() {
    insert opp;

    System.assertEquals(new List<SObject>{opp}, subject().values(), 'returns the list of SObjects');
  }

  static testMethod void keys() {
    insert opp;

    System.assertEquals(new Set<Id>{opp.id}, subject().keys(), 'returns the set of Ids');
  }

  static testMethod void mapBy() {
    insert opp;

    Map<Object, SObject> expectedMap = new Map<Object, SObject>{opp.Name => opp};

    System.assertEquals(expectedMap, subject().mapBy('Name'), 'maps by field name, caches, then returns catalog member');
  }

  static testMethod void listBy() {
    insert opp;

    Map<Object, List<SObject>> expectedMap = new Map<Object, List<SObject>>{opp.Name => new List<SObject>{opp}};
    System.assertEquals(expectedMap, subject().listBy('Name'), 'returns lists by attributes');
  }

  static SObjectCatalog subject() {
    return new SObjectCatalog([SELECT Id, StageName, Name, CloseDate FROM Opportunity]);
  }
}
