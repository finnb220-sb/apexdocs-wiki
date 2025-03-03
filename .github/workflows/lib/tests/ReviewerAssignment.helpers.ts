import { Context } from '@actions/github/lib/context';
import { GitHub } from '@actions/github/lib/utils';
import { jest } from '@jest/globals';
import { ActionConfiguration, PullRequestData } from '../types/ReviewerAssignment.types.ts';

export default class helper {

    static buildGithubMock() : jest.Mocked<InstanceType<typeof GitHub>> {
        return {
            rest: {
                pulls: {
                    requestReviewers: jest.fn(),
                },
                issues: {
                    addLabels: jest.fn(),
                    createComment: jest.fn(),
                },
            },
            graphql: jest.fn(),
        } as unknown as jest.Mocked<InstanceType<typeof GitHub>>;
    }

    static buildGithubMockContext(prCreatorsUsername: string) : Context {
        return {
            repo: {
                owner: 'testOwner',
                repo: 'testRepo',
            },
            payload: {
                pull_request: {
                    number: 1,
                    user: {
                        login: prCreatorsUsername,
                    },
                    draft: false,
                },
            },
        } as unknown as Context;
    }

    static buildInvalidGithubMockContext() : Context {
        return {
            repo: {
                owner: 'testOwner',
                repo: 'testRepo',
            },
            payload: {

            },
        } as unknown as Context;
    }

    static buildDraftGithubMockContext() : Context {
        return {
            repo: {
                owner: 'testOwner',
                repo: 'testRepo',
            },
            payload: {
                pull_request: {
                    number: 1,
                    user: {
                        login: 'testUser',
                    },
                    draft: true,
                },
            },
        } as unknown as Context;
    }

    static buildMockActionConfig(): ActionConfiguration {
        return {
            primaryReviewerTeamName: "depeche-code",
            fullTeamsList: "sprint-jedis, the-a-team, the-alchemists, team-4, team-5, team-sus, team7",
            primaryReviewerMapping: new Map([
                    ["team7", "codefriar"],
                    ["sprint-jedis", "bfinngoaldc"],
                    ["the-a-team", "jwelt94"],
                    ["team4", "omar"],
                    ["team5", "initdotd"],
                    ["the-alchemists", "justinstroudbah"]
            ]),
            temporarilyUnassignableUsersCsv: "codefriar",
            solutionArchitectTeamMapping: '{"sprint-jedis":"rstewartVA","the-a-team":"bwvidro","the-alchemists":"hartp-va","team-4":"philipjensenVA","team-5":"robert-booth1","team-sus":"malmanger", "team7":"malmanger"}',
            vahcTeamMapping: '{"team7": ["unassignableUser"], "sprint-jedis":["testUser","ttn614","Dsivey","MaryAnn95","MackmillerFrederick"],"the-a-team":["Jakobanana","EyouelB"],"the-alchemists":["sfdcDesign","carrera328","jpcoakes","benjaminmelvin85","adams84"],"team-4":["3sneha","LjoeVA","KyMartin67"],"team-5":["matthew-zolp","nicholas-capra","patrick-skamarak","D-Schofield","rajeevhoare","maurice-chesire-va","denver-leyba"],"team-sus":["abbiedaniel","lnewell23"]}'
        };
    }

    static graphQLResponseForReviewLoad: PullRequestData = {"repository":{"pullRequests":{"nodes":[{"reviewRequests":{"totalCount":1,"nodes":[{"requestedReviewer":{"login":"initdotd"}}]}},{"reviewRequests":{"totalCount":3,"nodes":[{"requestedReviewer":{"login":"robert-booth1"}},{"requestedReviewer":{"login":"justinstroudbah"}},{"requestedReviewer":{"login":"initdotd"}}]}},{"reviewRequests":{"totalCount":0,"nodes":[]}},{"reviewRequests":{"totalCount":0,"nodes":[]}},{"reviewRequests":{"totalCount":2,"nodes":[{"requestedReviewer":{"login":"bfinngoaldc"}},{"requestedReviewer":{"login":"jwelt94"}}]}},{"reviewRequests":{"totalCount":0,"nodes":[]}},{"reviewRequests":{"totalCount":1,"nodes":[{"requestedReviewer":{"login":"bfinngoaldc"}}]}},{"reviewRequests":{"totalCount":2,"nodes":[{"requestedReviewer":{"login":"PastranaDigital"}},{"requestedReviewer":{"login":"bwvidro"}}]}},{"reviewRequests":{"totalCount":0,"nodes":[]}},{"reviewRequests":{"totalCount":3,"nodes":[{"requestedReviewer":{"login":"wagnerJ-VA"}},{"requestedReviewer":{"login":"John-Ansardi"}},{"requestedReviewer":{"login":"farazK-VA"}}]}},{"reviewRequests":{"totalCount":1,"nodes":[{"requestedReviewer":{"login":"initdotd"}}]}},{"reviewRequests":{"totalCount":0,"nodes":[]}},{"reviewRequests":{"totalCount":2,"nodes":[{"requestedReviewer":{"login":"jwelt94"}},{"requestedReviewer":{"login":"robert-booth1"}}]}},{"reviewRequests":{"totalCount":0,"nodes":[]}},{"reviewRequests":{"totalCount":2,"nodes":[{"requestedReviewer":{"login":"bfinngoaldc"}},{"requestedReviewer":{"login":"robert-booth1"}}]}},{"reviewRequests":{"totalCount":2,"nodes":[{"requestedReviewer":{"login":"bfinngoaldc"}},{"requestedReviewer":{"login":"robert-booth1"}}]}},{"reviewRequests":{"totalCount":2,"nodes":[{"requestedReviewer":{"login":"philipjensenVA"}},{"requestedReviewer":{"login":"bfinngoaldc"}}]}},{"reviewRequests":{"totalCount":1,"nodes":[{"requestedReviewer":{"login":"bfinngoaldc"}}]}},{"reviewRequests":{"totalCount":0,"nodes":[]}},{"reviewRequests":{"totalCount":3,"nodes":[{"requestedReviewer":null},{"requestedReviewer":{"login":"codefriar"}},{"requestedReviewer":{"login":"bfinngoaldc"}}]}},{"reviewRequests":{"totalCount":0,"nodes":[]}},{"reviewRequests":{"totalCount":0,"nodes":[]}},{"reviewRequests":{"totalCount":0,"nodes":[]}},{"reviewRequests":{"totalCount":0,"nodes":[]}},{"reviewRequests":{"totalCount":0,"nodes":[]}},{"reviewRequests":{"totalCount":1,"nodes":[{"requestedReviewer":{"login":"codefriar"}}]}},{"reviewRequests":{"totalCount":0,"nodes":[]}},{"reviewRequests":{"totalCount":2,"nodes":[{"requestedReviewer":{"login":"PastranaDigital"}},{"requestedReviewer":{"login":"justinstroudbah"}}]}}]}}} as PullRequestData;

    static buildMockGraphQLResponseForTeamMembers() {
        return {
            organization: {
                'sprint-jedis': { members: { nodes: [{ login: 'testUser' }] } },
                'the-a-team': { members: { nodes: [{ login: 'otherUser' }] } },
                'the-alchemists': { members: { nodes: [{ login: 'anotherUser' }] } },
                'team-4': { members: { nodes: [{ login: 'yetAnotherUser' }] } },
                'team-5': { members: { nodes: [{ login: 'oneMoreUser' }] } },
                'team-sus': { members: { nodes: [{ login: 'lastUser' }] } },
                'team7': { members: { nodes: [{ login: 'unassignableUser' }] } }
            }
        };
    }
}