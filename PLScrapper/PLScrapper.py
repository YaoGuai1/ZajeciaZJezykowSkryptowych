import requests
from bs4 import BeautifulSoup
import pandas as pd
import openpyxl


def find_team_stats(name_of_team_to_get, year_of_end_the_season):

    place = 0
    played = 0
    wins = 0
    draws = 0
    losses = 0
    goals_scored = 0
    goals_conceded = 0
    goals_difference = 0
    points = 0
    url = 'https://www.skysports.com/premier-league-table/' + str(year_of_end_the_season)
    page = requests.get(url)

    if(page.status_code != 200):
        print("cannot load page properly, status code: ", page.status_code)
        return

    soup = BeautifulSoup(page.text, 'html.parser')

    league = soup.find('table', class_='standing-table__table')

    league_table = league.find_all('tbody')

    for league_teams in league_table:
        rows = league_teams.find_all('tr')
        for row in rows:
            team_name = row.find('td', class_='standing-table__cell standing-table__cell--name').text.strip()
            if team_name == name_of_team_to_get:
                row = row.find_all('td')
                place = row[0].text.strip()
                played = row[2].text.strip()
                wins = row[3].text.strip()
                draws = row[4].text.strip()
                losses = row[5].text.strip()
                goals_scored = row[6].text.strip()
                goals_conceded = row[7].text.strip()
                goals_difference = row[8].text.strip()
                points = row[9].text.strip()

    return place, played, wins, draws, losses, goals_scored, goals_conceded, goals_difference, points


def build_dataset(names_of_team_to_get = [], years_of_end_the_season = []):
    stats = []
    for name in names_of_team_to_get:
        for year in years_of_end_the_season:
            team_stats = find_team_stats(name, year)
            if team_stats and team_stats[0] != 0:
                league_dict = {'name': name,
                               'year': year,
                               'points': team_stats[-1],
                               'place in table': team_stats[0],
                               'wins': team_stats[2],
                               'draw': team_stats[3],
                               'losses': team_stats[4],
                               'goals scored': team_stats[5],
                               'goals conceded': team_stats[6],
                               'goals difference': team_stats[7],
                               'game played': team_stats[1]}
                stats.append(league_dict)

    return pd.DataFrame(stats)


def saving_to_excel(data_frame, sorted_by):
    df_sorted = data_frame.sort_values(sorted_by)
    df_sorted.to_excel("league.xlsx", index=False)


df = build_dataset(["Chelsea", "Everton", "Arsenalll"], [2012, 2013, 2016, 124124])
print(df)
saving_to_excel(df, "year")

